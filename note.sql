-- Danh sách event monitor
SELECT SUBSTR(EVMONNAME,1,20) AS EVMON_NAME, TARGET_TYPE, MONSCOPE, AUTOSTART, WRITE_MODE, OWNER FROM SYSCAT.EVENTMONITORS WITH UR

-- Danh sách event monitor với các trường được định dạng
SELECT SUBSTR(EVMONNAME, 1, 20) AS EVMON_NAME, CASE TARGET_TYPE WHEN 'F' THEN 'File (F)' WHEN 'T' THEN 'Table (T)' WHEN 'P' THEN 'Pipe (P)' WHEN 'U' THEN 'Unformatted (U)' END AS TARGET_TYPE, CASE MONSCOPE WHEN 'G' THEN 'Global (G)' WHEN 'L' THEN 'Local (L)' WHEN 'T' THEN 'T' END AS MONSCOPE, AUTOSTART, CASE WRITE_MODE WHEN 'A' THEN 'Append (A)' WHEN 'R' THEN 'Replace (R)' END AS WRITE_MODE, OWNER FROM SYSCAT.EVENTMONITORS

-- Danh sách workload
SELECT SUBSTR(EVMONNAME,1,20) AS EVMON_NAME, TARGET_TYPE, OWNER FROM SYSCAT.WORKLOADS WITH UR

-- Liet ke event monitor cua db hien tai
-- EVENT_MON_STATE: 1 scalar function sẽ trả về trạng thái của các event monitor
SELECT substr(evmonname, 1, 30) as evmon_name FROM syscat.eventmonitors WHERE event_mon_state(evmonname) = 1 WITH UR

-- Truy vấn thông tin bufferpool
SELECT SUBSTR(BP_NAME,1,20) AS BP_NAME, MEMBER, AUTOMATIC, DIRECT_READS, DIRECT_READ_REQS, DIRECT_WRITES, DIRECT_WRITE_REQS, BP_CUR_BUFFSZ, POOL_DATA_P_READS, POOL_DATA_L_READS, BP_TBSP_USE_COUNT FROM TABLE(MON_GET_BUFFERPOOL(NULL,-1)) WITH UR

-- Truy vấn mức độ sủ dụng bufferpool
SELECT BUFFERPOOLID, BPNAME, NPAGES, PAGESIZE FROM SYSCAT.BUFFERPOOLS WITH UR

-- Kiểm tra mức độ bufferpool hiện tại
SELECT POOL_CUR_SIZE, POOL_MAX_SIZE FROM TABLE(MON_GET_BUFFERPOOL(NULL,-1)) WITH UR

-- Truy vấn thông tin container
SELECT varchar(container_name,70) as container_name, varchar(tbsp_name,20) as tbsp_name, pool_read_time FROM TABLE(MON_GET_CONTAINER('',-2)) AS t ORDER BY pool_read_time DESC WITH UR

-- Liệt kê container bị khóa
SELECT varchar(container_name, 70) as container_name FROM TABLE(MON_GET_CONTAINER('',-1)) AS t WHERE accessible = 0 WITH UR

-- Truy vấn mức độ sử dụng của container
SELECT varchar(container_name, 65) as container_name, fs_id, fs_used_size/1000 as fs_used_size, fs_total_size/1000 as fs_total_size, CASE WHEN fs_total_size > 0 THEN DEC(100*(FLOAT(fs_used_size)/FLOAT(fs_total_size)),5,2) ELSE DEC(-1,5,2) END as utilization FROM TABLE(MON_GET_CONTAINER('',-1)) AS t ORDER BY utilization DESC WITH UR

-- Giới hạn mức độ sử dụng CPU 80%
-- Chuyển setting giới hạn CPU sang yes: update dbm cfg using WLM_CPU_DISPATCHER YES, update db cfg for insvnd using WLM_CPU_LIMIT 80
CREATE SERVICE CLASS CPU_80 CPU LIMIT 80;
CREATE WORKLOAD WL_CPU_80 SYSTEM_USER('DB2AC3') SERVICE CLASS CPU_80;
GRANT USAGE ON WORKLOAD WL_CPU_80 TO DB2AC3;

-- Xóa user ra khỏi workload, chú ý không thể xóa user cuối cùng ra khỏi workloard, muốn xóa khỏi workload, thì thêm user khác vào rồi xóa user cần xóa đi
ALTER WORKLOAD WL_CPU_80 ADD SYSTEM_USER('DB2ADMIN') SERVICE CLASS CPU_80;
ALTER WORKLOAD WL_CPU_80 DROP SYSTEM_USER('DB2AC3') SERVICE CLASS CPU_80;
GRANT USAGE ON WORKLOAD WL_CPU_80 TO DB2ADMIN;

-- Truy vấn thông tin các connection
SELECT CURRENT_TIMESTAMP AS sample_time, application_handle, varchar(application_name,20) as APPLICATION_NAME, varchar(system_auth_id,15) as SYSTEM_AUTH_ID, varchar(client_hostname,20) as  CLIENT_HOSTNAME, varchar(CLIENT_WRKSTNNAME,20) as CLIENT_WRKSTNNAME, connection_start_time FROM TABLE(MON_GET_CONNECTION(NULL, -1)) ORDER BY CLIENT_HOSTNAME ASC WITH UR

SELECT CURRENT_TIMESTAMP AS sample_time, application_handle, varchar(application_name,20) as APPLICATION_NAME, varchar(system_auth_id,15) as SYSTEM_AUTH_ID, varchar(client_hostname,20) as  CLIENT_HOSTNAME, varchar(CLIENT_WRKSTNNAME,20) as CLIENT_WRKSTNNAME, connection_start_time FROM TABLE(MON_GET_CONNECTION(NULL, -1)) WHERE CLIENT_HOSTNAME = 'CXIVNXAP02' ORDER BY CLIENT_HOSTNAME ASC WITH UR

-- Truy vấn thông tin hoạt động trong DB2 kết hợp bảng ACTIVITY và CONNECTION
SELECT T1.APPLICATION_HANDLE, varchar(T2.APPLICATION_NAME,25) AS APPLICATION_NAME, varchar(T2.APPLICATION_ID,50) as APPLICAITON_ID, T1.UOW_ID, T1.ACTIVITY_ID, T1.ACTIVITY_STATE, varchar(T1.ACTIVITY_TYPE,15) as ACTIVITY_TYPE, T1.TOTAL_CPU_TIME, T1.ROWS_READ, T1.ROWS_RETURNED as ROWS_RETURNED FROM TABLE(MON_GET_ACTIVITY(NULL,-1)) T1 INNER JOIN TABLE(MON_GET_CONNECTION(NULL, -1)) T2 ON T1.APPLICATION_HANDLE=T2.APPLICATION_HANDLE ORDER BY T1.APPLICATION_HANDLE ASC WITH UR

SELECT T1.APPLICATION_HANDLE, varchar(T2.APPLICATION_NAME,25) AS APPLICATION_NAME, varchar(T2.APPLICATION_ID,50) as APPLICAITON_ID, T1.UOW_ID, T1.ACTIVITY_ID, T1.ACTIVITY_STATE, varchar(T1.ACTIVITY_TYPE,15) as ACTIVITY_TYPE, T1.TOTAL_CPU_TIME, T1.ROWS_READ, T1.ROWS_RETURNED as ROWS_RETURNED FROM TABLE(MON_GET_ACTIVITY(NULL,-1)) T1 FULL OUTER JOIN TABLE(MON_GET_CONNECTION(NULL, -1)) T2 ON T1.APPLICATION_HANDLE=T2.APPLICATION_HANDLE ORDER BY T1.APPLICATION_HANDLE ASC WITH UR

WITH ACT AS ( SELECT APPLICATION_HANDLE FROM TABLE(MON_GET_ACTIVITY(NULL, -2)) AS A ), CONN AS ( SELECT APPLICATION_HANDLE FROM TABLE(MON_GET_CONNECTION(NULL, -2)) AS C ) SELECT A.APPLICATION_HANDLE FROM ACT A LEFT JOIN CONN C ON A.APPLICATION_HANDLE = C.APPLICATION_HANDLE WHERE C.APPLICATION_HANDLE IS NULL WITH UR

-- Truy vấn thông tin các kết nối nhưng không thực hiện hoạt động nào trong DB2
WITH CONN AS ( SELECT APPLICATION_HANDLE, APPLICATION_NAME FROM TABLE(MON_GET_CONNECTION(NULL, -2)) AS C ), ACT AS ( SELECT APPLICATION_HANDLE FROM TABLE(MON_GET_ACTIVITY(NULL, -2)) AS A ) SELECT C.APPLICATION_HANDLE FROM CONN C LEFT JOIN ACT A ON C.APPLICATION_HANDLE = A.APPLICATION_HANDLE WHERE A.APPLICATION_HANDLE IS NULL WITH UR

-- Truy vấn thông tin các kết nối nhưng không thực hiện hoạt động nào trong DB2 (cách 2)
SELECT C.APPLICATION_HANDLE, SUBSTR(C.APPLICATION_NAME,1,25) AS APPLICATION_NAME, varchar(C.client_hostname,20) as  CLIENT_HOSTNAME, varchar(C.CLIENT_WRKSTNNAME,20) as CLIENT_WRKSTNNAME, C.connection_start_time, A.ACTIVITY_TYPE FROM TABLE(MON_GET_CONNECTION(NULL, -2)) C LEFT JOIN TABLE(MON_GET_ACTIVITY(NULL, -2)) A ON C.APPLICATION_HANDLE = A.APPLICATION_HANDLE WHERE A.ACTIVITY_TYPE is NULL WITH UR

-- Truy vấn thông tin các kết nối nhưng không thực hiện hoạt động nào trong DB2 (cách 2)
SELECT C.APPLICATION_HANDLE, SUBSTR(C.APPLICATION_NAME,1,25) AS APPLICATION_NAME, varchar(C.client_hostname,20) as  CLIENT_HOSTNAME, varchar(C.CLIENT_WRKSTNNAME,20) as CLIENT_WRKSTNNAME, C.connection_start_time, A.ACTIVITY_TYPE FROM TABLE(MON_GET_CONNECTION(NULL, -2)) C LEFT JOIN TABLE(MON_GET_ACTIVITY(NULL, -2)) A ON C.APPLICATION_HANDLE = A.APPLICATION_HANDLE WHERE A.ACTIVITY_TYPE is NULL WITH UR

-- Truy vấn tất cả các hoạt động bằng bảng ACTIVITY
SELECT APPLICATION_HANDLE, varchar(APPLICATION_NAME,25) AS APPLICATION_NAME, ACTIVITY_ID, ACTIVITY_STATE, varchar(ACTIVITY_TYPE,15) as ACTIVITY_TYPE, TOTAL_CPU_TIME, ROWS_READ, ROWS_RETURNED FROM TABLE(MON_GET_ACTIVITY(NULL,-1)) WITH UR

-- Truy vấn thông tin application hiện tại đang kết nối vào db2
select application_handle, application_name, application_id, member, rows_read from table(sysproc.mon_get_connection(sysproc.mon_get_application_handle(), -1)) as conn WITH UR

-- Truy vấn thông tin agent
SELECT APPLICATION_HANDLE, SUBSTR(APPLICATION_NAME,1,30) AS APPLICATION_NAME, VARCHAR(WORKLOAD_NAME,25) AS WORKLOAD_NAME, VARCHAR(SERVICE_SUPERCLASS_NAME,25) AS SERVICE_SUPERCLASS_NAME FROM TABLE(MON_GET_AGENT(NULL,NULL,NULL,-1)) WHERE WORKLOAD_NAME = 'WL_CPU_80' WITH UR 

-- Truy vấn thông tin lock
SELECT APPLICATION_HANDLE, MEMBER, VARCHAR(LOCK_OBJECT_TYPE,15) AS LOCK_OBJECT_TYPE, LOCK_MODE, LOCK_STATUS, LOCK_COUNT, LOCK_HOLD_COUNT, TBSP_ID, TAB_FILE_ID FROM TABLE(MON_GET_LOCKS(NULL,-1)) WHERE TAB_FILE_ID IS NOT NULL WITH UR

-- Truy vấn thông tin số lượng lock của từng table đang dc sử dụng
SELECT VARCHAR(LOCK_OBJECT_TYPE,15) AS LOCK_OBJECT_TYPE, TAB_FILE_ID, COUNT(*) AS NUM_LOCKS FROM TABLE(MON_GET_LOCKS(NULL, -1)) WHERE TAB_FILE_ID IS NOT NULL GROUP BY TAB_FILE_ID,LOCK_OBJECT_TYPE ORDER BY NUM_LOCKS DESC WITH UR

-- Truy vấn thông tin lock với tên table 
SELECT SUBSTR(RTRIM(T.TABSCHEMA) || '.' || RTRIM(T.TABNAME),1,45) AS TAB_FNAME, L.APPLICATION_HANDLE, L.LOCK_NAME, VARCHAR(L.LOCK_OBJECT_TYPE_ID,10) AS LOCK_OBJECT_TYPE_ID, VARCHAR(L.LOCK_OBJECT_TYPE,15) AS LOCK_OBJECT_TYPE, L.LOCK_MODE, L.LOCK_STATUS, L.LOCK_COUNT, L.LOCK_HOLD_COUNT, L.TBSP_ID, L.TAB_FILE_ID FROM TABLE(MON_GET_LOCKS(NULL,-1)) AS L LEFT JOIN TABLE(MON_GET_TABLE('','',-1)) AS T ON L.TAB_FILE_ID=T.TAB_FILE_ID WHERE L.TAB_FILE_ID IS NOT NULL AND T.TABNAME='DTFBT001' WITH UR

-- Truy vấn thông tin lock với lock mode là X,IX,U
SELECT APPLICATION_HANDLE, MEMBER, LOCK_NAME, VARCHAR(LOCK_OBJECT_TYPE_ID,10) AS LOCK_OBJECT_TYPE_ID, VARCHAR(LOCK_OBJECT_TYPE,15) AS LOCK_OBJECT_TYPE, LOCK_MODE, LOCK_STATUS, LOCK_COUNT, LOCK_HOLD_COUNT, TBSP_ID, TAB_FILE_ID FROM TABLE(MON_GET_LOCKS(NULL,-1)) WHERE TAB_FILE_ID IS NOT NULL AND LOCK_MODE IN ('X','IX','U') WITH UR

-- Truy vấn thông tin lockwait
SELECT LOCK_WAIT_START_TIME, LOCK_NAME, VARCHAR(LOCK_OBJECT_TYPE_ID,10) AS LOCK_OBJECT_TYPE_ID, VARCHAR(LOCK_OBJECT_TYPE,15) AS LOCK_OBJECT_TYPE, LOCK_MODE, LOCK_MODE_REQUESTED, LOCK_STATUS, LOCK_COUNT, REQ_APPLICATION_HANDLE, HLD_APPLICATION_HANDLE FROM TABLE(MON_GET_APPL_LOCKWAIT(NULL,-1)) WITH UR

-- Truy vấn danh sách các bảng tạo bởi user được áp dụng audit
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABNAME, TYPE, AUDITPOLICYID, VARCHAR(AUDITPOLICYNAME,25) AS AUDITPOLICYNAME FROM SYSCAT.TABLES WHERE RTRIM(TABSCHEMA) LIKE 'DB__' AND TYPE='T' AND AUDITPOLICYID IS NOT NULL WITH UR

-- Truy vấn danh sách các table dc tạo bởi user
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.ROWS_READ, T1.ROWS_INSERTED, T1.ROWS_UPDATED, T1.ROWS_DELETED, T1.TABLE_SCANS, T1.TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) T1 INNER JOIN TABLE(MON_GET_TABLESPACE(NULL,-1)) T2 ON T1.TBSP_ID = T2.TBSP_ID WHERE TAB_TYPE = 'USER_TABLE' AND TABSCHEMA NOT IN ('DB2ADMIN','DB2INST1','SYSTOOLS') ORDER BY T1.TABLE_SCANS DESC WITH UR

-- Truy vấn danh sách catalog table
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.TABLE_SCANS, TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) WHERE TAB_TYPE = 'CATALOG_TABLE' WITH UR

-- Truy vấn danh sách các bảng tạm 
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.TABLE_SCANS, TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) T1 INNER JOIN TABLE(MON_GET_TABLESPACE(NULL,-1)) T2 ON T1.TBSP_ID = T2.TBSP_ID WHERE TAB_TYPE = 'TEMP_TABLE' WITH UR

-- Truy vấn thông tin REORG của các table
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.ROWS_READ, T1.ROWS_INSERTED, T1.ROWS_UPDATED, T1.ROWS_DELETED, T1.PAGE_REORGS, T1.TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) T1 INNER JOIN TABLE(MON_GET_TABLESPACE(NULL,-1)) T2 ON T1.TBSP_ID = T2.TBSP_ID WHERE TAB_TYPE = 'USER_TABLE' AND TABSCHEMA NOT IN ('DB2ADMIN','DB2INST1','SYSTOOLS') ORDER BY T1.PAGE_REORGS DESC WITH UR

-- Truy vấn mức độ sử dụng các trang trong bảng
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, NPAGES, MPAGES, FPAGES, PCTFREE FROM SYSCAT.TABLES WHERE TABSCHEMA NOT IN ('SYSIBM','SYSCAT','SYSSTAT','SYSPUBLIC','SYSIBMADM','SYSTOOLS','DB2ADMIN','DB2AC3') ORDER BY FPAGES DESC

-- Truy vấn thông tin index
SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, IID AS INDEX_ID, NLEAF, NLEVELS, INDEX_SCANS, INDEX_ONLY_SCANS, KEY_UPDATES FROM TABLE(MON_GET_INDEX(NULL,NULL,-2)) WHERE TABSCHEMA NOT IN ('DB2INST1','DB2ADMIN','SYSIBM','SYSTOOLS') WITH UR

-- Truy vấn thông tin index của 1 bảng
SELECT VARCHAR(S.INDSCHEMA, 10) AS INDSCHEMA, VARCHAR(S.INDNAME, 30) AS INDNAME, VARCHAR(S.COLNAMES,100) AS COLNAMES, T.DATA_PARTITION_ID, T.MEMBER, T.INDEX_SCANS, T.INDEX_ONLY_SCANS FROM TABLE(MON_GET_INDEX('DBAC', 'DTACB300_ADJUST', -2)) as T, SYSCAT.INDEXES AS S WHERE T.TABSCHEMA = S.TABSCHEMA AND T.TABNAME = S.TABNAME AND T.IID = S.IID ORDER BY INDEX_SCANS DESC

-- Truy vấn thông tin index xem cần REORG hay không
select TABSCHEMA, TABNAME, IID, INDSCHEMA, INDNAME, INDEX_OBJECT_L_SIZE, INDEX_OBJECT_P_SIZE, INDEX_REQUIRES_REBUILD, RECLAIMABLE_SPACE from table(ADMIN_GET_INDEX_INFO('','DBAT','DTATA404'))

-- Truy vấn quyền hạn của bảng
SELECT VARCHAR(GRANTOR,15) AS GRANTOR, VARCHAR(GRANTEE,15) AS GRANTEE, VARCHAR(TABNAME,40) AS TABNAME, CONTROLAUTH, ALTERAUTH, DELETEAUTH, INSERTAUTH, SELECTAUTH, UPDATEAUTH FROM SYSCAT.TABAUTH WHERE TABNAME = 'DTATZ972' WITH UR

-- Truy vấn trạng thái tablespace
SELECT SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, SUBSTR(TBSP_STATE,1,18) AS TBSP_STATE FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME LIKE '%DATA' WITH UR  

-- Truy vấn thông tin cơ bản các tablespace
SELECT SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, TBSP_TYPE, TBSP_PAGE_SIZE, TBSP_EXTENT_SIZE, TBSP_PREFETCH_SIZE, FS_CACHING, TBSP_REBALANCER_MODE, TBSP_USING_AUTO_STORAGE, TBSP_AUTO_RESIZE_ENABLED FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME LIKE '%DATA' WITH UR

-- Truy vấn các trang của tablespace
SELECT TBSP_USED_PAGES, TBSP_FREE_PAGES, TBSP_USABLE_PAGES, TBSP_TOTAL_PAGES, TBSP_PENDING_FREE_PAGES, TBSP_PAGE_TOP, TBSP_ID, SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME = 'DBAADATA' WITH UR

SELECT TBSP_USED_PAGES, TBSP_FREE_PAGES, TBSP_USABLE_PAGES, TBSP_TOTAL_PAGES, TBSP_PENDING_FREE_PAGES, TBSP_PAGE_TOP, TBSP_ID, SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, TBSP_EXTENT_SIZE FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME = 'DBZSDATA' ORDER BY TBSP_TOTAL_PAGES DESC WITH UR

SELECT TBSP_USED_PAGES, TBSP_FREE_PAGES, TBSP_USABLE_PAGES, TBSP_TOTAL_PAGES, TBSP_PENDING_FREE_PAGES, TBSP_PAGE_TOP, TBSP_ID, SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, TBSP_EXTENT_SIZE FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME LIKE '%DATA' ORDER BY TBSP_TOTAL_PAGES DESC WITH UR

SELECT SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, TBSP_ID, REBALANCER_MODE, REBALANCER_STATUS, REBALANCER_EXTENTS_REMAINING FROM TABLE(MON_GET_REBALANCE_STATUS('',-2))

-- Tuy vấn các bảng trong tablespaces 
SELECT SUBSTR(TABSCHEMA,1,30) AS TABSCHEMA, SUBSTR(TABNAME,1,30) AS TABNAME, TBSPACE FROM SYSCAT.TABLES WHERE TBSPACE = 'DBZSDATA' ORDER BY TABSCHEMA ASC WITH UR

-- Truy vấn thông tin PCTFREE của bảng
SELECT SUBSTR(TABSCHEMA,1,30) AS TABSCHEMA, SUBSTR(TABNAME,1,30) AS TABNAME, SUBSTR(TBSPACE,1,30) AS TBSPACE, PCTFREE, PCTEXTENDEDROWS FROM SYSCAT.TABLES WHERE TBSPACE = 'DBZSDATA' ORDER BY TABSCHEMA ASC WITH UR

-- Truy vấn thông tin các trang của bảng
SELECT SUBSTR(TABSCHEMA,1,30) AS TABSCHEMA, SUBSTR(TABNAME,1,30) AS TABNAME, SUBSTR(TBSPACE,1,30) AS TBSPACE, NPAGES, MPAGES, FPAGES FROM SYSCAT.TABLES WHERE TBSPACE = 'DBZSDATA' AND TABSCHEMA NOT IN ('DB2INST1','SYSTOOLS') ORDER BY TABSCHEMA ASC WITH UR

-- Truy vấn thông tin danh sách các admin task, chú ý phải bật reg DB2_ATS_ENABLE=YES thì mới có thể sử dụng
SELECT SUBSTR(NAME,1,30) AS NAME, TASKID, SUBSTR(OWNER,1,30) AS OWNER, OWNERTYPE, BEGIN_TIME, END_TIME, MAX_INVOCATIONS, SCHEDULE, PROCEDURE_SCHEMA, PROCEDURE_NAME, PROCEDURE_INPUT, OPTIONS FROM SYSTOOLS.ADMIN_TASK_LIST

-- Truy vấn thông tin HADR
SELECT HADR_ROLE,REPLAY_TYPE,HADR_SYNCMODE,HADR_STATE,SUBSTR(PRIMARY_MEMBER_HOST,1,20),SUBSTR(STANDBY_MEMBER_HOST,1,20),HADR_CONNECT_STATUS,HADR_LOG_GAP,PRIMARY_LOG_POS,STANDBY_LOG_POS,PRIMARY_LOG_TIME,STANDBY_LOG_FILE FROM TABLE(MON_GET_HADR(-1))

-- Truy vấn thông tin RUNSTAT lần cuối của DB2
SELECT TABSCHEMA, TABNAME, INDSCHEMA, INDNAME, STATS_TIME FROM SYSCAT.INDEXES WHERE INDSCHEMA NOT IN ('SYSIBM','DB2INST1','SYSTOOLS')
--WHERE TABSCHEMA = 'HR' AND TABNAME = 'EMPLOYEES';

-- Truy vấn thông tin các index đang có
SELECT TABSCHEMA, TABNAME, INDSCHEMA, INDNAME, INDEXTYPE, COLNAMES, TBSPACEID, PCTFREE FROM SYSCAT.INDEXES WHERE INDSCHEMA NOT IN ('SYSIBM','DB2INST1','SYSTOOLS') --AND INDEXTYPE <> 'REG'

-- 
SELECT SUBSTR(TABSCHEMA,1,45),SUBSTR(TABNAME,1,45) FROM SYSCAT.TABLES
-- Cấp quyền user
GRANT SELECT ON TABLE DBAT.DTATZ972 TO USER DB2AC3

-- Truy vấn thông tin của 1 bảng cụ thể 
SELECT varchar(tabschema, 20) as tabschema, varchar(tabname, 40) as tabname, sum(rows_read) as total_rows_read, sum(rows_inserted) as total_rows_inserted, sum(rows_updated) as total_rows_updated, sum(rows_deleted) as total_rows_deleted FROM TABLE(MON_GET_TABLE('', '', -2)) AS t where tabname='DTFMA000_PMD_MEMO_LOG' GROUP BY tabschema, tabname ORDER BY total_rows_read DESC

-- Truy vấn dung lượng vật lý của bảng (đơn vị là KB)
SELECT SUBSTR(TABNAME,1,30) AS TABNAME, DATA_OBJECT_P_SIZE, INDEX_OBJECT_P_SIZE, LONG_OBJECT_P_SIZE, LOB_OBJECT_P_SIZE, XML_OBJECT_P_SIZE FROM SYSIBMADM.ADMINTABINFO WHERE TABNAME = 'DTATA400';

-- Truy vấn tổng dung lượng của 1 bảng (đơn vị là KB)
select tabschema || '.' || tabname as table, ( ( data_object_p_size + index_object_p_size + long_object_p_size + lob_object_p_size + xml_object_p_size ) / 1024 ) as physical_space, ( ( data_object_l_size + index_object_l_size + long_object_l_size + lob_object_l_size + xml_object_l_size ) / 1024 ) as logical_space from sysibmadm.admintabinfo where tabschema NOT LIKE 'SYS%' and tabschema NOT LIKE 'DB2INST1%' and tabschema NOT LIKE 'DB2ADMIN%' FETCH FIRST 10 ROWS ONLY;

-- Kiểm tra bảng có cần reorg hay không
REORGCHK CURRENT STATISTICS ON TABLE T1
RUNSTATS ON TABLE T1 WITH DISTRIBUTION AND DETAILED INDEXES ALL
-- Tạo bảng 
CREATE TABLE DBAE.DTAET100 (
    ID INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    ITERATION INT NOT NULL,
    BONUS_SETTING_NAME VARCHAR(255) NOT NULL, -- tên công thức
    TIME_FRAME VARCHAR(2) NOT NULL,  -- 1: Tháng, 2: Quý, 3: Tháng tích lũy
    START_DATE DATE NOT NULL,
    END_DATE DATE NOT NULL,
    CRT_EMPNO VARCHAR(20),
    UPD_EMPNO VARCHAR(20),
    CRT_TM TIMESTAMP,
    UPD_TM TIMESTAMP,
    PRIMARY KEY (ID),
    CONSTRAINT UQ_BonusSetting UNIQUE (ITERATION, START_DATE, END_DATE)
) IN DBAEDATA INDEX IN DBAEINDX;
GRANT SELECT ON TABLE DBAE.DTAET100 TO USER DB2AC3;

-- Bật Append ON
ALTER TABLE DBAE.DTAEK200_LOG APPEND ON;

-- Tắt auto COMMIT
UPDATE COMMAND OPTIONS USING C OFF;

-- In chuỗi
SELECT 'Hello World' FROM SYSIBM.SYSDUMMY1;

-- Cắt khoảng trắng trong chuỗi
SELECT TRIM('   Hello World   ') FROM SYSIBM.SYSDUMMY1;

-- Cắt chuỗi
SELECT SUBSTR('Hello World', 1, 5) FROM SYSIBM.SYSDUMMY1;

-- Chuyển sang ký tự hoa
SELECT UPPER('Hello World') FROM SYSIBM.SYSDUMMY1;  

-- Chuyển sang ký tự thường
SELECT LOWER('Hello World') FROM SYSIBM.SYSDUMMY1;

-- Đếm độ dài chuỗi
SELECT LENGTH('Hello World') FROM SYSIBM.SYSDUMMY1;

-- Xóa dữ liệu của DB không nên quá 10 tr bản ghi trên bảng, vì khi xóa no sẽ sinh ra archive log, nếu xóa quá nhiều sẽ làm cho archive log tăng lên nhanh chóng, làm treo database, nên cân nhắc trước khi xóa có thể nghĩ đến phương pháp truncate, tuy nhiên truncate sẽ không redo, undo dc dữ liệu. Trong Oracle thì muốn undo lại dữ liệu thì sử dụng flashback. Trong oracle sử dụng undo retention hoặc undo tablespace phải đủ lớn để lưu dữ liệu cũ.

--  Partition --
-- Chú ý: Trong điều kiện partion, nên kết hợp với dev để biết trong câu lệnh là gì, có quét partition hay không.
-- Tại sao phải partition: Bảng lớn dần, đến ngưỡng 100tr bản ghi -> khó dọn dẹp, select dữ liệu khó.
-- Khi nào partition:
-- Khi bảng dữ liệu > 2GB (khoảng 50tr bản ghi) => cân nhắc partition (theo ngày, theo tháng ,  ...)
-- Dữ liệu lịch sử => quy luật xoay vòng dữ liệu => Nghiệp vụ: muốn lưu lâu dài, DBA: muốn tối ưu, 2 bên nên thương lượng để đửa ra quy trình hợp lý, nếu không thì xem xét giữ lại dữ liệu trong khoảng thời gian nhất định, sau đó xóa đi.
-- Dữ liệu nào cần truy xuất nhiều, update nhiều thì nên để partition ở phân vùng có thể truy xuất nhanh, còn dữ liệu ít truy xuất thì có thể để ở phân vùng khác, không cần truy xuất nhiều.
-- Các loại partition trong Oracle: range partition (theo ngày, theo number), list partition (ví dụ theo tỉnh thành: HCM, Hà Nội, Đà Nẵng,...), Hash partition (láy 1 trường ra làm tiêu chí để partition, ví dụ số điện thoại, email), composite partition (kết hợp các loại partition trên).
-- Chia nhỏ thêm từ partition thì gọi là composite partition.
-- Độ lớn partition: từ 10k row trở đi. (100k - 1tr, 2tr là phù hợp), tuy nhiên tùy vào trường hợp lưu trữ là OLTP hoặc OLAP. OLTP là phải nhanh, phần lớn phải có index trên OLTP. Datawarehouse thì lại không cần index, nên dùng parrallel (4 ,8, 16, ...) và tùy vào tài nguyên.
-- Lưu trữ partition: Có data thì có index tương ứng. 
-- Index: nên dùng index local.
-- Bảng càng lớn thì index càng lớn.
-- Chu kỳ lưu trữ: rà soát lại dữ liệu theo quy trình, log thì lưu trữ 1 tháng, 3 tháng, 6 tháng, ... tùy vào quy trình của từng công ty.

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ORACLE -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- ORA-01653
-- unable to increase tablespace tablespace_name by storage_allocatedstorage_units during insert or update on table schema_name.table_name
-- tablespace_name: The name of the tablespace that is supposed to be extended during the operation.
-- storage_allocated: The number of bytes in KB, MB, or GB for the attempted allocation.
-- storage_units: The unit of bytes in KB, MB, or GB in which storage is allocated.
-- schema_name: The schema name of table.
-- table_name: The table name.
-- Cause
-- In order to execute the insert or update operation, additional space is needed in the tablespace. However, the system is unable to increase the tablespace.

-- Action
-- Depending on the tablespace attributes and storage strategy, take one of the following actions:

-- Resize the tablespace using either the ALTER DATABASE DATAFILE RESIZE or ALTER TABLESPACE ADD DATAFILE statement.
-- Enable AUTOEXTEND for the tablespace.
-- If AUTOEXTEND is already enabled:
-- And MAXSIZE is set to UNLIMITED, increase the storage media where the tablespace is located.
-- Increase MAXSIZE.
-- If it is a BIGFILE tablespace, use the ALTER TABLESPACE RESIZE
-- statement to increase the tablespace.
-- Sửa lỗi ORA-01653
-- Tăng dung lượng của tablespace
ALTER DATABASE DATAFILE 'path_to_datafile' RESIZE new_size;
-- Hoặc
ALTER TABLESPACE tablespace_name ADD DATAFILE 'path_to_new_datafile' SIZE new_size;
-- Truy vấn thông tin dung lượng của các tablespace trong Oracle
SELECT 
    b.tablespace_name, 
    ROUND(b.tbs_size, 2) AS SizeMb, 
    ROUND(a.free_space, 2) AS FreeMb
FROM  
    (SELECT 
        tablespace_name, 
        ROUND(SUM(bytes) / 1024 / 1024, 2) AS free_space
     FROM 
        dba_free_space
     GROUP BY 
        tablespace_name) a
JOIN 
    (SELECT 
        tablespace_name, 
        ROUND(SUM(bytes) / 1024 / 1024, 2) AS tbs_size
     FROM 
        dba_data_files
     GROUP BY 
        tablespace_name) b
ON a.tablespace_name = b.tablespace_name;
