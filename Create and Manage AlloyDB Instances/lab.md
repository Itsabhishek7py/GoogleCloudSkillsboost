


## 💡 Lab Link: [Create and Manage AlloyDB Instances: Challenge Lab - GSP395](https://www.cloudskillsboost.google/focuses/100853?parent=catalog)

## 🚀 Lab Solution [Watch Here]()

---

## 💡 [Open this link in new tab](https://console.cloud.google.com/alloydb/clusters?referrer=search&project=)


### 💡 Active your Cloud Shell & click (+) icon to launch 2nd Cloud Terminal

1. Export the **ZONE** Name correctly in **both Cloud Terminal**
```
export ZONE=$(gcloud compute instances list --filter="name=alloydb-client" --format='csv[no-heading](zone)')
```

2. Run the below commands in your **First Cloud Terminal**
```
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Create%20and%20Manage%20AlloyDB%20Instances/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```
---
3. Switch back to **Second Cloud Terminal**

4. Connect **SSH** of **`alloydb-client`**
```
gcloud compute ssh alloydb-client --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --quiet
```

3. **Replacing ALLOYDB_ADDRESS with the Private IP address of the AlloyDB instance**
```
export ALLOYDB=
```

4. Below commands **store the Private IP address of the AlloyDB instance on the AlloyDB client VM**
```
echo $ALLOYDB  > alloydbip.txt 
```

5. This commands launch the **PostgreSQL (psql) client**
```
psql -h $ALLOYDB -U postgres
```
---
- You will be prompted to provide the postgres user's password **(Change3Me)** which you entered when you created the **cluster
R TABLE departments ADD PRIMARY KEY (department_id)**;

```
CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25)
) ;
ALTER TABLE regions ADD PRIMARY KEY (region_id);
```

```
CREATE TABLE countries (
    country_id char(2) NOT NULL,
    country_name varchar(40),
    region_id bigint
) ;
ALTER TABLE countries ADD PRIMARY KEY (country_id);
```

```
CREATE TABLE departments (
    department_id smallint NOT NULL,
    department_name varchar(30),
    manager_id integer,
    location_id smallint
) ;
ALTER TABLE departments ADD PRIMARY KEY (department_id);
```

```
INSERT INTO regions VALUES ( 1, 'Europe' );
INSERT INTO regions VALUES ( 2, 'Americas' );
INSERT INTO regions VALUES ( 3, 'Asia' );
INSERT INTO regions VALUES ( 4, 'Middle East and Africa' );
```

```
INSERT INTO countries VALUES ('IT', 'Italy', 1 );
INSERT INTO countries VALUES ('JP', 'Japan', 3  );
INSERT INTO countries VALUES ('US', 'United States of America', 2  );
INSERT INTO countries VALUES ('CA', 'Canada', 2  );
INSERT INTO countries VALUES ('CN', 'China', 3  );
INSERT INTO countries VALUES ('IN', 'India', 3 );
INSERT INTO countries VALUES ('AU', 'Australia', 3  );
INSERT INTO countries VALUES ('ZW', 'Zimbabwe', 4  );
INSERT INTO countries VALUES ('SG', 'Singapore', 3 );
```

```
INSERT INTO departments VALUES (10, 'Administration', 200, 1700 );
INSERT INTO departments VALUES (20, 'Marketing', 201, 1800);
INSERT INTO departments VALUES (30, 'Purchasing', 114, 1700 );
INSERT INTO departments VALUES (40, 'Human Resources', 203, 2400);
INSERT INTO departments VALUES (50, 'Shipping', 121, 1500);
INSERT INTO departments VALUES (60, 'IT', 103, 1400);
```

---

### Congratulations !!!!

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.  

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 

---


---
