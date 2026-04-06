package com.example.bigdata;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class FootballCombiner extends Reducer<Text, Text, Text, Text> {

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {

        int sumMatches = 0;
        int sumGoals = 0;

        for (Text value : values) {
            try {
                String[] parts = value.toString().split(",", -1);
                if (parts.length < 2) {
                    continue;
                }

                int matches = Integer.parseInt(parts[0].trim());
                int goals = Integer.parseInt(parts[1].trim());

                sumMatches += matches;
                sumGoals += goals;
            } catch (Exception e) {
                // Ignore malformed input value and keep processing
            }
        }

        context.write(key, new Text(sumMatches + "," + sumGoals));
    }
}
