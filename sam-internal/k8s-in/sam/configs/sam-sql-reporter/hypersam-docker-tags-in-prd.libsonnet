{
      name: "HyperSam Docker Tags in PRD",
      note: "Currently running hypersam tag for sam-system deployments and daemon sets owned by sam",
      multisql: [
        {
          name: "Hypersam in prd-samtest (Phase 0)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-samtest' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
        {
          name: "Hypersam in prd-samdev (Phase 1)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-samdev' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
        {
          name: "Hypersam in prd-sam (Phase 2)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-sam' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
      ],
    }