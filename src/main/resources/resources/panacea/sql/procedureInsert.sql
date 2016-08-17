--from procedure_occurrence
INSERT INTO @pnc_ptsq_ct (job_execution_id, study_id, person_id, source_id, concept_id, concept_name, idx_start_date, idx_end_date, duration_days)
SELECT distinct @jobExecId as job_execution_id, @studyId AS study_id, myCohort.person_id AS person_id, @sourceId AS source_id, proc.procedure_concept_id,
--  myConcept.concept_name, proc.procedure_date, myObservation.end_date, myObservation.end_date - proc.procedure_date + 1
  myConcept.concept_name, proc.procedure_date, myObservation.end_date, DATEDIFF(DAY, proc.procedure_date, myObservation.end_date) + 1
--FROM @results_schema.panacea_study study
--INNER JOIN (SELECT DISTINCT COHORT_DEFINITION_ID COHORT_DEFINITION_ID, subject_id person_id, COHORT_START_DATE cohort_start_date, cohort_end_date cohort_end_date FROM @ohdsi_schema.cohort
from (SELECT DISTINCT COHORT_DEFINITION_ID COHORT_DEFINITION_ID, subject_id person_id, COHORT_START_DATE cohort_start_date, cohort_end_date cohort_end_date FROM @ohdsi_schema.cohort
--		WHERE COHORT_DEFINITION_ID = @cohortDefId AND subject_id in (2000000030415658, 2000000032622347, 2000000000085043,2000000000090467,2000000000118598,2000000000125769,2000000000125769,2000000000239227,2000000000239227,2000000000239227,2000000000239227,2000000000631458,2000000000959184,2000000000959184,2000000000959184,2000000001023133,2000000001050023,2000000001198966,2000000001198966,2000000001328233,2000000001328233,2000000001556222,2000000001572262,2000000001598664,2000000001663228,2000000001705565,2000000001705565,2000000001724335,2000000001913150,2000000001913150,2000000001915668,2000000001915668,2000000001953187,2000000001978178,2000000002067964,2000000002120363,2000000002265649,2000000002382712,2000000002382712,2000000002403404,2000000002857369,2000000002975421,2000000003048921,2000000003175220,2000000003395250,2000000003613126,2000000003622138,2000000008400409,2000000008400723,2000000008419771,2000000008419771,2000000008587433,2000000003395250,2000000026715825,2000000028349554,2000000045463331,2000000049663233,2000000050900029,2000000091077892,2000000144174555,2000000220342782))  myCohort
--       WHERE COHORT_DEFINITION_ID = @cohortDefId AND subject_id in (2000000030415658, 2000000032622347))  myCohort
        WHERE COHORT_DEFINITION_ID = @cohortDefId)  myCohort
--ON myCohort.COHORT_DEFINITION_ID = study.COHORT_DEFINITION_ID
INNER JOIN @cdm_schema.procedure_occurrence proc
  ON myCohort.person_id = proc.person_id
  AND proc.procedure_concept_id in (@procedureConceptId)
  AND (proc.PROCEDURE_DATE > myCohort.COHORT_START_DATE OR proc.PROCEDURE_DATE = myCohort.COHORT_START_DATE) 
--  AND (proc.PROCEDURE_DATE < myCohort.COHORT_START_DATE + study.STUDY_DURATION OR proc.PROCEDURE_DATE = myCohort.COHORT_START_DATE + study.STUDY_DURATION)
--  AND (proc.PROCEDURE_DATE < DATEADD(day, study.STUDY_DURATION, myCohort.COHORT_START_DATE) OR proc.PROCEDURE_DATE = DATEADD(day, study.STUDY_DURATION, myCohort.COHORT_START_DATE))
  AND (proc.PROCEDURE_DATE < DATEADD(day, @STUDY_DURATION, myCohort.COHORT_START_DATE) OR proc.PROCEDURE_DATE = DATEADD(day, @STUDY_DURATION, myCohort.COHORT_START_DATE))
  @procedureStudyOptionalDateConstraint
INNER JOIN @cdm_schema.concept myConcept
ON proc.procedure_concept_id = myConcept.concept_id
INNER JOIN (SELECT observationPeriod.PERSON_ID PERSON_ID, max(OBSERVATION_PERIOD_END_DATE) end_date 
	from @cdm_schema.observation_period observationPeriod
	where observationPeriod.person_id in (SELECT DISTINCT subject_id FROM @ohdsi_schema.cohort
    WHERE  COHORT_DEFINITION_ID = @cohortDefId)
	group by observationPeriod.person_id) myObservation
ON myObservation.PERSON_ID = myCohort.person_id
--WHERE
--    study.study_id = @studyId
WHERE myCohort.COHORT_DEFINITION_ID = @COHORT_DEFINITION_ID
ORDER BY person_id, procedure_date;
