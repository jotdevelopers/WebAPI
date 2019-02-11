CREATE OR REPLACE VIEW ${ohdsiSchema}.prediction_analysis_generation as
  SELECT
    job.job_execution_id                     id,
    job.create_time                          start_time,
    job.end_time                             end_time,
    job.status                               status,
    job.exit_message                         exit_message,
    CAST(plp_id_param.string_val AS INTEGER) prediction_id,
    CAST(source_param.string_val AS INTEGER) source_id,
    -- Generation info based
    NULL as                                  design
  FROM ${ohdsiSchema}.batch_job_execution job
    JOIN ${ohdsiSchema}.batch_job_execution_params plp_id_param ON job.job_execution_id = plp_id_param.job_execution_id AND plp_id_param.key_name = 'prediction_analysis_id'
    JOIN ${ohdsiSchema}.batch_job_execution_params source_param ON job.job_execution_id = source_param.job_execution_id AND source_param.key_name = 'source_id'
    LEFT JOIN ${ohdsiSchema}.analysis_generation_info gen_info ON job.job_execution_id = gen_info.job_execution_id
  ORDER BY start_time DESC;