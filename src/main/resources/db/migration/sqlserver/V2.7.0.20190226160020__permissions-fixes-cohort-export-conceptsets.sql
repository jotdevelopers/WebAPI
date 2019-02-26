ALTER TABLE ${ohdsiSchema}.sec_permission ADD for_role_id INTEGER;
GO

INSERT INTO ${ohdsiSchema}.sec_permission(id, value, description, for_role_id)
SELECT NEXT VALUE FOR ${ohdsiSchema}.sec_permission_id_seq, REPLACE(CAST(new_perms.val AS VARCHAR(255)), '%s', REPLACE(REPLACE(value, 'cohortdefinition:*:generate:', ''), ':get', '')),
  REPLACE(CAST(new_perms.description AS VARCHAR(255)), '%s', REPLACE(REPLACE(value, 'cohortdefinition:*:generate:', ''), ':get', '')), role_id
FROM ${ohdsiSchema}.sec_permission sp
  JOIN ${ohdsiSchema}.sec_role_permission srp on sp.id = srp.permission_id
  CROSS JOIN (
               SELECT 'cohortdefinition:%s:export:conceptset:get' val, 'Export ConceptSet for Source with key=%s' description
             ) new_perms
WHERE sp.value LIKE 'cohortdefinition:*:generate:%:get' AND sp.value <> 'cohortdefinition:*:generate:*:get';

INSERT INTO ${ohdsiSchema}.sec_role_permission (id, role_id, permission_id)
  SELECT NEXT VALUE FOR ${ohdsiSchema}.sec_role_permission_sequence, sp.for_role_id, sp.id
  FROM ${ohdsiSchema}.sec_permission sp
  WHERE sp.for_role_id IS NOT NULL;

ALTER TABLE ${ohdsiSchema}.sec_permission DROP COLUMN for_role_id;