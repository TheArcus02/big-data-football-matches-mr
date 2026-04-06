package com.example.bigdata;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class FootballMatches {

    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println(
                    "Usage: FootballMatches <input_dir1> <output_dir3> [local|cluster]");
            System.exit(2);
        }

        String mode = args.length >= 3 ? args[2] : "cluster";
        if (!"local".equalsIgnoreCase(mode) && !"cluster".equalsIgnoreCase(mode)) {
            System.err.println("Third argument must be 'local' or 'cluster'. Got: " + mode);
            System.exit(2);
        }

        Configuration conf = new Configuration();
        if ("local".equalsIgnoreCase(mode)) {
            conf.set("mapreduce.framework.name", "local");
            conf.set("fs.defaultFS", "file:///");
            conf.set("mapreduce.jobtracker.address", "local");
        }

        Job job = Job.getInstance(conf, "football matches stats");

        job.setJarByClass(FootballMatches.class);
        job.setMapperClass(FootballMapper.class);
        job.setCombinerClass(FootballCombiner.class);
        job.setReducerClass(FootballReducer.class);

        job.setOutputFormatClass(TextOutputFormat.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        Path inputPath = new Path(args[0]);
        Path outputPath = new Path(args[1]);

        FileInputFormat.addInputPath(job, inputPath);

        FileSystem fs = outputPath.getFileSystem(conf);
        if (fs.exists(outputPath)) {
            fs.delete(outputPath, true);
        }
        FileOutputFormat.setOutputPath(job, outputPath);

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
