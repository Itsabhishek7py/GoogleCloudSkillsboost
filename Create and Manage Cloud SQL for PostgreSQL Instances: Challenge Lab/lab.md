
# Create and Manage Cloud SQL for PostgreSQL Instances: Challenge Lab

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)]()


---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Dr Abhishek](https://www.youtube.com/@drabhishek.5460/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏




## Enable the following Google APIs:
```bash
gcloud services enable datamigration.googleapis.com --quiet
gcloud services enable servicenetworking.googleapis.com --quiet
```
---

## Compute Engine > VM instances > Connect the SSH of postgresql-vm

- **install the pglogical database extension and jquery**
```
sudo apt install postgresql-14-pglogical
```

- **Download and apply some additions to the PostgreSQL configuration files (to enable pglogical extension)**
```
sudo su - postgres -c "gsutil cp gs://cloud-training/gsp918/pg_hba_append.conf ."
sudo su - postgres -c "gsutil cp gs://cloud-training/gsp918/postgresql_append.conf ."
sudo su - postgres -c "cat pg_hba_append.conf >> /etc/postgresql/14/main/pg_hba.conf"
sudo su - postgres -c "cat postgresql_append.conf >> /etc/postgresql/14/main/postgresql.conf"
sudo systemctl restart postgresql@14-main
```

- **Apply required privileges to postgres and orders databases**

```
sudo su - postgres
```

```
psql
```
Run above command 2 times
```
\c postgres;
```

```
CREATE EXTENSION pglogical;
```
Run above command 2 times
```
\c orders;
```

```
CREATE EXTENSION pglogical;
```
---

### Open the below website

- **[Online word replacer](https://textcompare.io/word-replacer)**

```
CREATE USER migration_admin PASSWORD 'DMS_1s_cool!';
ALTER DATABASE orders OWNER TO migration_admin;
ALTER ROLE migration_admin WITH REPLICATION;


\c orders;


SELECT column_name FROM information_schema.columns WHERE table_name = 'inventory_items' AND column_name = 'id';
ALTER TABLE inventory_items ADD PRIMARY KEY (id);


GRANT USAGE ON SCHEMA pglogical TO migration_admin;
GRANT ALL ON SCHEMA pglogical TO migration_admin;
GRANT SELECT ON pglogical.tables TO migration_admin;
GRANT SELECT ON pglogical.depend TO migration_admin;
GRANT SELECT ON pglogical.local_node TO migration_admin;
GRANT SELECT ON pglogical.local_sync_status TO migration_admin;
GRANT SELECT ON pglogical.node TO migration_admin;
GRANT SELECT ON pglogical.node_interface TO migration_admin;
GRANT SELECT ON pglogical.queue TO migration_admin;
GRANT SELECT ON pglogical.replication_set TO migration_admin;
GRANT SELECT ON pglogical.replication_set_seq TO migration_admin;
GRANT SELECT ON pglogical.replication_set_table TO migration_admin;
GRANT SELECT ON pglogical.sequence_state TO migration_admin;
GRANT SELECT ON pglogical.subscription TO migration_admin;



GRANT USAGE ON SCHEMA public TO migration_admin;
GRANT ALL ON SCHEMA public TO migration_admin;
GRANT SELECT ON public.distribution_centers TO migration_admin;
GRANT SELECT ON public.inventory_items TO migration_admin;
GRANT SELECT ON public.order_items TO migration_admin;
GRANT SELECT ON public.products TO migration_admin;
GRANT SELECT ON public.users TO migration_admin;



ALTER TABLE public.distribution_centers OWNER TO migration_admin;
ALTER TABLE public.inventory_items OWNER TO migration_admin;
ALTER TABLE public.order_items OWNER TO migration_admin;
ALTER TABLE public.products OWNER TO migration_admin;
ALTER TABLE public.users OWNER TO migration_admin;



\c postgres;


GRANT USAGE ON SCHEMA pglogical TO migration_admin;
GRANT ALL ON SCHEMA pglogical TO migration_admin;
GRANT SELECT ON pglogical.tables TO migration_admin;
GRANT SELECT ON pglogical.depend TO migration_admin;
GRANT SELECT ON pglogical.local_node TO migration_admin;
GRANT SELECT ON pglogical.local_sync_status TO migration_admin;
GRANT SELECT ON pglogical.node TO migration_admin;
GRANT SELECT ON pglogical.node_interface TO migration_admin;
GRANT SELECT ON pglogical.queue TO migration_admin;
GRANT SELECT ON pglogical.replication_set TO migration_admin;
GRANT SELECT ON pglogical.replication_set_seq TO migration_admin;
GRANT SELECT ON pglogical.replication_set_table TO migration_admin;
GRANT SELECT ON pglogical.sequence_state TO migration_admin;
GRANT SELECT ON pglogical.subscription TO migration_admin;
```

## Create Connection Profile:

## For Database Migration: Click [Here](https://console.cloud.google.com/dbmigration/migrations?)
```bash
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Create%20and%20Manage%20Cloud%20SQL%20for%20PostgreSQL%20Instances%3A%20Challenge%20Lab/drabhishek.sh
sudo chmod +x drabhishek.sh
./drabhishek.sh
```

---

### Task 3. Implement Cloud SQL for PostgreSQL IAM database authentication

- **Asking For a password enter**

```
supersecret!
```
> Copy and paste the password and the password will not visible to you

```
\c orders
```

- **Asking For a password enter**
```
supersecret!
```
> Copy and paste the password and the password will not visible to you

---

- ⚠️ **Change the TABLE_NAME and USER_NAME by given lab instructions**
```
GRANT ALL PRIVILEGES ON TABLE [TABLE_NAME] TO "USER_NAME";

\q
```

---

### Task 4. Configure and test point-in-time recovery

```
date --rfc-3339=seconds
```
> Copy the given output and Save this

- **Asking For a password enter**
```
supersecret!
```
> Copy and paste the password and the password will not visible to you


```
\c orders
```

- **Asking For a password enter**
```
supersecret!
```
> Copy and paste the password and the password will not visible to you

```
insert into distribution_centers values(-80.1918,25.7617,'Miami FL',11);
\q
```

```
gcloud auth login --quiet

gcloud projects get-iam-policy $DEVSHELL_PROJECT_ID
```

```
gcloud sql instances clone [CLOUDSQL_INSTANCE] [NEW_INSTANCE_NAME] \
 --point-in-time "[TIME_STAMP]"
```
<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Channel"/>
</a>

<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Group"/>
</a>

<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>

<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000" alt="YouTube"/>
</a>

<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F" alt="Instagram"/>
</a>

<a href="https://www.facebook.com/people/Dr-Abhishek/61580947955153/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white&labelColor=1877F2" alt="Facebook"/>
</a>

<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000" alt="X (Twitter)"/>
</a>

</div>

</div>
