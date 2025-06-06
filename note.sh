# Lenh db2 hay dung
su - db2inst1
db2top
db2start

# Cho db2 tu khoi dong
db2iauto -on db2inst1
db2 set DB2_ATS_ENABLE=YES
db2 set DB2COMM=TCPIP
db2 set DB2AUTOSTART=YES

# Khoi dong HADR
db2 start hadr on db $db as standby
db2 start hadr on db $db as primary

db2 deactivate db $db
db2 stop hadr on db $db

# Cac thiet lap de chay hadr
db2 update db cfg for $db USING HADR_LOCAL_HOST SV1
db2 update db cfg for $db USING HADR_REMOTE_HOST SV2
db2 update db cfg for $db USING HADR_LOCAL_SVC 51601
db2 update db cfg for $db USING HADR_REMOTE_SVC 51601
db2 update db cfg for $db USING HADR_REMOTE_INST DB2INST1
db2 update db cfg for $db USING HADR_SYNCMODE SYNC
db2 update db cfg for $db USING HADR_PEER_WINDOW 30
db2 update db cfg for $db USING LOGINDEXBUILD ON
db2 update db cfg for $db USING INDEXREC RESTART

# Dua db ve trang thai normal
## Truong hop 1: cac file log van con du
db2 rollforward db $db to end of logs and complete

db2 describe table
db2 drop db crm
db2 drop db hadb
db2 get dbm cfg | grep -i dbpath
db2 list db directory
db2pd -db insvndb -dbcfg
db2pd -db insvndb -logs
db2pd -db insvndb -transaction

# Lenh linux Hay dung
ps -ef | grep db2sysc
ssh root@192.168.100.10
ssh root@192.168.100.253 -i .ssh/pve-secondary
ssh root@192.168.100.250 -i .ssh/pve-secondary
ssh root@192.168.100.247 -i .ssh/pve-secondary
ssh manager@192.168.100.240
yum update -y
yum upgrade -y
getenforce
source .bashrc

# Vi tri luu log batch tren 48.2

# Lenh Git hay dung
git add .
git commit -m "commit"
git push
git pull

# Xem ip
ip -c addr

# Doi IP (NetworkManager)
nmcli connection modify ens18 ipv4.method manual
nmcli connection modify ens18 ipv4.addresses 192.168.100.250/24
nmcli connection modify ens18 ipv4.gateway 192.168.100.1
nmcli connection modify ens18 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up ens18

# Tat SELINUX
sed 's\SELINUX=enforcing\SELINUX=disabled\' /etc/selinux/config
setenforce disabled
reboot

# Danh sach txlog cho insvndb
cd /db2txlog/INSVNDB/NODE0000/LOGSTREAM0000/
ls -lh /db2txlog/INSVNDB/NODE0000/LOGSTREAM0000/

# Danh sach arclog cho insvndb 
cd /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000/
ls -lh /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000/

# Describe bang
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

#Thay the chuoi
sed 's\\'
tr '-' ';'

#Xoa 1 ky tu cuoi gia tri bien
${TEN_BIEN::-1}

#Tim kiem chuoi ip 
 grep server1 basic.cfg | grep -oP "ip1=\K[^|]+"
 
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

# Cài đặt corosync-qnetd từ bộ cài đặt của DB2 11.5.9.0
cd /server_dec/db2/linuxamd64/pcmk/Linux/rhel/rhel8/x86_64
dnf install corosync-qnetd-3.0.3-1.db2pcmk.el8.x86_64.rpm



# Cấu trúc chuẩn file inventory.yml
all:
  children:
    linux-first:
        hosts:
          192.168.100.250:
          192.168.100.247:

# Cấu trúc chuẩn của playbook.yml
- name: Playbook for Linux First
  hosts: all
  become: true
  vars:
    admin_user: # Lấy từ vault
    admin_password: # Lấy từ vault
  tasks:
    - name: Ensure packages are installed
      yum:
        name:
          - vim
          - git
        state: present

    - name: Create a directory
      file:

# Các câu lệnh của ansible hay dùng
# Tạo vault với nano
EDITOR=nano ansible-vault create secrets.yml # Đặt pass cho vault
# Gắn vault vào trong playbook với cấu trúc như sau:
vars_files:
    - secrets.yml
  vars:
    ansible_user: "{{ admin_user }}"
    ansible_password: "{{ admin_password }}"
    ansible_ssh_host_key_checking: false

# Chạy playbook với vault
ansible-playbook -i inventory.yml playbook.yml --ask-vault-pass

# Chạy playbook với vault và không cần nhập pass
ansible-playbook -i inventory.yml playbook.yml --vault-password-file ~/.vault_pass.txt

# Mã hóa vault_pass.txt
openssl enc -aes-256-cbc -salt -in vault_pass.txt -out vault_pass.txt.enc

# Chạy playbook với vault đã mã hóa
ansible-playbook -i inventory.yml playbook.yml --vault-password-file ~/.vault_pass.txt.enc