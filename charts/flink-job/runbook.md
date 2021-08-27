## NoFlinkJobRunning

### What's Happening?

There is no flink job running in this flink job cluster. This is likely because the job is cancelled. 

### Where can I look for more information?

You should check out the flink dashboard for the current status of the cluster and the job manager logs. 

### What should I do to resolve this alarm?

You need to identify what is causing the job to be canceled first and restart the job. 

## FlinkJobOutage

The flink job is down. The exceptions tab in Flink console is a good place to start looking. You can look at the job manager and task manager logs. 

## FlinkJobTooManyRestarts

The flink job is restarting too frequently. You should find out what is causing the restart. The common issues we have encountered in the past are connection resets for example. 

## FlinkCheckpointFailing

The flink job manager fails to save the checkpoint. This alarm is a good proxy of the overall health of the flink job. Checking status of the job and exception history is a good place to start. 