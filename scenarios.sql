create extension if not exists "uuid-ossp";

----------------------------
-- 1. Plan new exposition --
----------------------------
select *
from exposition;

select *
from expositionstate;

select *
from exhibitioninformation;

-- Test 1 - pass: Plan an exposition without conflicts
call plan_exposition(
        exposition_name := 'Exposition 1',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000001']::uuid[],
        exposition_description := 'This is a description for Exposition 1',
        expositionstate_description := 'This is a state description for Exposition 1',
        exposition_start_date := '2024-05-15 00:00:00.000000',
        exposition_end_date := '2024-05-31 23:59:59.999999'
     );

-- Test 2 - fail: Plan a new exposition with a planning zone conflict
-- First, we plan an exposition in the same zone - pass
call plan_exposition(
        exposition_name := 'Exposition 2',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000001']::uuid[], -- Assuming this zone ID exists in database
        exposition_description := 'This is a description for Exposition 2',
        expositionstate_description := 'This is a state description for Exposition 2',
        exposition_start_date := '2024-06-01 00:00:00.000000',
        exposition_end_date := '2024-06-30 23:59:59.999999'
     );

-- Then, we try to plan another exposition in the same zone and the same time period, which should raise an exception - fail
call plan_exposition(
        exposition_name := 'Exposition 3',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000001']::uuid[],
        exposition_description := 'This is a description for Exposition 3',
        expositionstate_description := 'This is a state description for Exposition 3',
        exposition_start_date := '2024-06-15 00:00:00.000000',
        exposition_end_date := '2024-07-15 23:59:59.999999'
     );

-- Test 3 - fail: Plan a new exposition with a planning zone conflict time collision - planning without end date
call plan_exposition(
        exposition_name := 'Exposition 4',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000001']::uuid[],
        exposition_description := 'This is a description for Exposition 4',
        expositionstate_description := 'This is a state description for Exposition 4',
        exposition_start_date := '2024-05-01 00:00:00.000000'
     );

---------------------------------
-- 2. Insert of a new exemplar --
---------------------------------
select *
from exemplar;

select *
from exemplarstate;

select *
from category;

select *
from exemplarownership;

select *
from institution;

-- Test 1 - pass: Insert a new exemplar with a non-existing categories
call insert_new_exemplar(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000001',
        exemplar_name := 'exemplar 1',
        exemplar_description := 'exemplar 1 description',
        exemplar_year := '0100-01-01',
        exemplar_estprice := 100000,
        exemplar_location := 'location 1',
        category_names := array ['category1', 'category2', 'machine learning']::varchar(100)[], -- creates new categories 1 and 2
        category_descriptions := array ['description1', 'description2', null]::varchar(255)[],
        owner_institution_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-3b3b3b3b3b3b', 'f0b3b3b3-3b3b-3b3b-3b3b-3b3b3b3b3b3c']::uuid[],
        owner_acquisition_date := array ['2022-01-01 21:16:17.293281', '2022-01-01 21:16:17.293281']::timestamp[],
        owner_share := array [0.5]::float4[]
     );

-- Test 2 - fail: Insert a new exemplar with a non-existing institution
call insert_new_exemplar(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000002',
        exemplar_name := 'exemplar 2',
        exemplar_description := 'exemplar 2 description',
        exemplar_year := '0100-01-01',
        exemplar_estprice := 100000,
        exemplar_location := 'location 2',
        category_names := array ['data science']::varchar(100)[],
        category_descriptions := array ['description1', 'description2', null]::varchar(255)[],
        owner_institution_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-3b3b3b3b3b3f']::uuid[],
        owner_acquisition_date := array ['2022-01-01 21:16:17.293281']::timestamp[],
        owner_share := array [0.5]::float4[]
     );

-- Test 3 - pass: Insert another new exemplar
call insert_new_exemplar(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000003',
        exemplar_name := 'exemplar 3',
        exemplar_description := 'exemplar 3 description',
        exemplar_year := '0100-01-01',
        exemplar_estprice := 100000,
        exemplar_location := 'location 3',
        exemplarstate_location_status := 'IN_TRANSIT',
        category_names := array ['blockchain']::varchar(100)[],
        category_descriptions := array ['description1']::varchar(255)[],
        owner_institution_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-3b3b3b3b3b3b']::uuid[],
        owner_acquisition_date := array ['2022-01-01 21:16:17.293281']::timestamp[],
        owner_share := array [1]::float4[]
     );

-------------------------------------------
-- 3. Move of the exemplar to other zone --
-------------------------------------------
select *
from exposition;

select *
from expositionstate;

select *
from exhibitioninformation;

select *
from exemplarstate;

-- pass - First, we create some ongoing expositions and make sure to crete exemplars
call plan_exposition(
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000001',
        exposition_name := 'Exposition ONGOING 1',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000001', 'f0b3b3b3-3b3b-3b3b-3b3b-000000000002']::uuid[],
        exposition_state := 'ONGOING',
        exposition_description := 'This is a description for Exposition ONGOING 1',
        expositionstate_description := 'This is a state description for Exposition ONGOING 1',
        exposition_start_date := now()::timestamp,
        exposition_end_date := '2024-05-1 00:00:00.000000'
     );

call plan_exposition(
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002',
        exposition_name := 'Exposition ONGOING 2',
        zone_ids := array ['f0b3b3b3-3b3b-3b3b-3b3b-000000000003']::uuid[],
        exposition_state := 'ONGOING',
        exposition_description := 'This is a description for Exposition ONGOING 2',
        expositionstate_description := 'This is a state description for Exposition ONGOING 2',
        exposition_start_date := now()::timestamp,
        exposition_end_date := '2024-05-1 00:00:00.000000'
     );

-- Test 1 - fail: Move an exemplar to a zone that does not exist
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000001',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000000',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000001'
     );

-- Test 2 - fail: Move an exemplar which does not exist
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000000',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000001',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002'
     );

-- Test 3 - fail: Move an exemplar to exposition which does not exist
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000000',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000001',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002'
     );

-- Test 4 - fail: Move an exemplar which is in transit
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000003',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000001',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002'
     );

-- Test 5 - fail: Move an exemplar 1 to exposition 2 which is not in zone 1
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000001',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000001',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002'
     );

-- Test 6 - pass: Move an exemplar 1 to exposition 1 into zone 2
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000001',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000002',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000001'
     );

-- Test 7 - pass: Move an exemplar 1 to exposition 2 into zone 3
call move_exemplar_to_zone(
        exemplar_id := 'f0e3e3e3-3e3e-3e3e-3e3e-000000000001',
        zone_id := 'f0b3b3b3-3b3b-3b3b-3b3b-000000000003',
        exposition_id := 'f0c3c3c3-3c3c-3c3c-3c3c-000000000002'
     );

----------------------------------------------------------------
-- 4. Acquire back borrowed exemplar from another institution --
----------------------------------------------------------------
select *
from exemplarstate e
where e.exemplarid = 'f0e3e3e3-3e3e-3e3e-3e3e-000000000003';

-- Test 1 - pass: Acquire back exemplar 4
call acquire_back_exemplar('f0e3e3e3-3e3e-3e3e-3e3e-000000000004');

-- Test 2 - fail: Acquire back exemplar 4 again which is not in transit
call acquire_back_exemplar('f0e3e3e3-3e3e-3e3e-3e3e-000000000004');

---------------------------------------------------
-- 5. Borrow the exemplar from other institution --
---------------------------------------------------
select *
from exemplar;

select *
from exemplarstate;

select *
from exemplarownership;

select *
from institution;

-- Test 1 - pass: Acquire exemplar 5
call acquire_new_exemplar_from_institution(
        exemplar_name := 'exemplar 5',
        exemplar_description := 'exemplar 5 description',
        exemplar_year := '0100-01-01',
        exemplar_estprice := 100000,
        exemplar_location := 'location 5',
        category_names := array ['blockchain', 'artificial intelligence']::varchar(100)[],
        category_descriptions := array ['description1', 'description2']::varchar(255)[],
        owner_institution_emails := array ['technology@museum.com', 'inst4@seznam.cz']::varchar(100)[],
        owner_acquisition_date := array ['2022-01-01 21:16:17.293281', '2022-01-01 21:16:17.293281']::timestamp[],
        owner_share := array [0.7, 0.3]::float4[],
        institution_name := 'Institution 4',
        institution_address := 'Address 4',
        institution_email := 'inst4@seznam.cz',
        institution_type := 'UNIVERSITY',
        institution_phone := '1234512345',
        institution_website := 'www.inst4.cz',
        institution_description := 'This is a description for Institution 4'
     );

-- Test 2 - fail: Acquire exemplar 6 from non existing institution
call acquire_new_exemplar_from_institution(
        exemplar_name := 'exemplar 6',
        exemplar_description := 'exemplar 6 description',
        exemplar_year := '0100-01-01',
        exemplar_estprice := 100000,
        exemplar_location := 'location 6',
        category_names := array ['blockchain', 'artificial intelligence']::varchar(100)[],
        category_descriptions := array ['description1', 'description2']::varchar(255)[],
        owner_institution_emails := array ['random@museum.com', 'inst4@seznam.cz']::varchar(100)[],
        owner_acquisition_date := array ['2022-01-01 21:16:17.293281', '2022-01-01 21:16:17.293281']::timestamp[],
        owner_share := array [0.7, 0.3]::float4[],
        institution_name := 'Institution 4',
        institution_address := 'Address 4',
        institution_email := 'inst4@seznam.cz',
        institution_type := 'UNIVERSITY',
        institution_phone := '1234512345',
        institution_website := 'www.inst4.cz',
        institution_description := 'This is a description for Institution 4'
     );
