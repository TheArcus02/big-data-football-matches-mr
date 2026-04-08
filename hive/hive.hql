ADD JAR ${hiveconf:hcatalog_jar};

USE default;

DROP TABLE IF EXISTS mr_results;
CREATE EXTERNAL TABLE mr_results (
  team_id STRING,
  season STRING,
  matches_played INT,
  avg_goals_per_match DOUBLE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  'input.regex'='([^,]+),([^\\t]+)\\t([^,]+),(.*)'
)
STORED AS TEXTFILE
LOCATION '${hiveconf:input_dir3}';

DROP TABLE IF EXISTS teams;
CREATE EXTERNAL TABLE teams (
  team_id STRING,
  name STRING,
  city STRING,
  league STRING,
  coach STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES (
  'skip.header.line.count'='1'
);

DROP TABLE IF EXISTS league_output;
CREATE EXTERNAL TABLE league_output (
  league STRING,
  total_matches BIGINT,
  avg_goals_per_match DOUBLE,
  teams_ranking ARRAY<STRUCT<team_id:STRING, rank_in_league:INT>>
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '${hiveconf:output_dir6}';

WITH team_league AS (
  SELECT
    m.team_id,
    m.season,
    m.matches_played,
    m.avg_goals_per_match,
    t.league
  FROM mr_results m
  JOIN teams t
    ON m.team_id = t.team_id
  WHERE t.league IS NOT NULL
),
team_totals AS (
  SELECT
    league,
    team_id,
    SUM(matches_played) AS sum_matches_team
  FROM team_league
  GROUP BY league, team_id
),
team_ranked AS (
  SELECT
    league,
    team_id,
    CAST(RANK() OVER (PARTITION BY league ORDER BY sum_matches_team DESC) AS INT) AS rank_in_league
  FROM team_totals
),
league_stats AS (
  SELECT
    league,
    SUM(matches_played) AS total_matches,
    CASE
      WHEN SUM(matches_played) = 0 THEN 0.0
      ELSE SUM(matches_played * avg_goals_per_match) / SUM(matches_played)
    END AS avg_goals_per_match
  FROM team_league
  GROUP BY league
)
INSERT OVERWRITE TABLE league_output
SELECT
  ls.league,
  ls.total_matches,
  ls.avg_goals_per_match,
  collect_list(
    named_struct(
      'team_id', tr.team_id,
      'rank_in_league', tr.rank_in_league
    )
  ) AS teams_ranking
FROM league_stats ls
JOIN team_ranked tr
  ON ls.league = tr.league
GROUP BY ls.league, ls.total_matches, ls.avg_goals_per_match;
