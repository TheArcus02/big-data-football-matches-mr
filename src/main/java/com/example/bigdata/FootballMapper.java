package com.example.bigdata;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;


public class FootballMapper extends Mapper<LongWritable, Text, Text, Text> {

    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        String line = value.toString();
        if (line.startsWith("match_id")) {
            return;
        }

        try {
            String[] fields = line.split(",", -1);
            if (fields.length < 6) {
                return;
            }

            String homeTeamId = fields[1].trim();
            String awayTeamId = fields[2].trim();
            int homeScore = Integer.parseInt(fields[3].trim());
            int awayScore = Integer.parseInt(fields[4].trim());

            LocalDateTime dateTime = LocalDateTime.parse(fields[5].trim(), DATE_FORMAT);
            int month = dateTime.getMonthValue();
            int year = dateTime.getYear();
            int season = month >= 8 ? year : year - 1;

            Text homeKey = new Text(homeTeamId + "," + season);
            Text awayKey = new Text(awayTeamId + "," + season);
            Text homeVal = new Text("1," + homeScore);
            Text awayVal = new Text("1," + awayScore);

            context.write(homeKey, homeVal);
            context.write(awayKey, awayVal);
        } catch (Exception e) {
        }
    }
}
