#Danh sach txlog cho insvndb
cd /db2txlog/INSVNDB/NODE0000/LOGSTREAM0000/
ls -lh /db2txlog/INSVNDB/NODE0000/LOGSTREAM0000/

#Danh sach arclog cho insvndb 
cd /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000/
ls -lh /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000/

#Describe bang
db2 describe table SYSCAT.TABAUTH

# Thiet lap Gioi han su dung CPU cho DB2
su - db2inst1
db2 connect to insvndb
db2 update dbm cfg using WLM_CPU_DISPATCHER YES
db2 update db cfg for insvnd using WLM_CPU_LIMIT 80

# Fix explain table db2 sau khi nang cap
db2 "CALL SYSPROC.SYSINSTALLOBJECTS('EXPLAIN', 'C', CAST (NULL AS VARCHAR(128)), CAST (NULL AS VARCHAR(128)))"
db2exmig -d insvndb -e db2inst1

# Import du lieu tu file ixf
db2 "import from data.ixf of ixf insert into table"

#Ap dung audit cho table
db2 audit table <schema>.<table> using policy AUDIT_DB_EXECUTE

#Trich xuat du lieu db2 audit
db2audit extract 

#Trich xuat cau truc bang
db2look -d insvndb -t DBAB.DTABA403 -e -z DBAB -o DBAB.DTABA403.sql

#Backup toan bo db
db2 "backup db insvndb online to /dbbackup/BACKUP"

#Backup tablespace 
db2 "backup db insvndb tablespace DBZSDATA online to /dbbackup/BACKUP"

## Khi 1 tablespace roi vao trang thai backup pending, hay thuc hien backup ngay o cho do online cho rieng tablespace do

# Tim va xoa file
find . -type f -name "*.LOG" -mmin +1000 -exec rm -rf {} \;
find . -type f -name "*.LOG" -mtime +1 -exec rm -rf {} \;

#Mo rong logic volume
lvextend -L +5G /dev/datavg/db2data /dev/sda
resire2fs /dev/datavg/db2data

#Thu nho logic volume
lvresize -L -5G /dev/datavg/db2data
#Chu y, phai unmount roi moi resize2fs
resire2fs /dev/datavg/db2data

#Khoa user
passwd -l u1
usermod -L u1

#Mo khoa user
passwd -u u1
usermod -U u1

#Dat ngay het han cho account (Account expire)
chage -E YYYY-mm-dd u1
#Dat ngay het han mk cho user
chage -m YYYY-mm-dd u1

#Chinh ngay het han passwd mac dinh cho user moi
nano /etc/login.defs
vi /etc/login.defs

#Xoa khoang trang
echo " Hello" | tr -d ' '

#Xoa 1 ky tu cuoi gia tri bien
${TEN_BIEN::-1}

#So sanh chuoi
if [ ${TEN_BIEN} -eq "ABC" ];then
    echo "Bang nhau"
fi

#So sanh so
if [ ${TEN_BIEN} == 1 ];then
    echo "Bang 1"
fi


#Chú ý:
#Trước khi đọc giá trị từ một file vào trong shellscript mà giá trị đó là số thì hãy xóa khoảng trắng đi trước khi đưa vào
#Linux sử dụng LF, windows sử dụng CRLF