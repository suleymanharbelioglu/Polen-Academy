# Fix: "Default service account doesn't exist"

Cloud Functions needs the **default Compute Engine service account**. It is created when you enable the **Compute Engine API**.

## Option A – Google Cloud Console (easiest)

1. Open: **https://console.cloud.google.com/**
2. Select project: **polen-academy** (top bar).
3. Left menu: **APIs & Services** → **Library** (or **Enable APIs and Services**).
4. Search for **Compute Engine API**.
5. Open it and click **Enable**.
6. Wait 1–2 minutes for the default service account to be created.
7. Deploy again from the project root:
   ```powershell
   cd c:\flutter_folder\mobile\projects\polen_academy
   firebase deploy --only "functions"
   ```

## Option B – gcloud CLI

If you have **gcloud** installed:

```powershell
gcloud config set project polen-academy
gcloud services enable compute.googleapis.com
```

Then run `firebase deploy --only "functions"` again.

---

After enabling Compute Engine API, the account  
`325336282488-compute@developer.gserviceaccount.com` will exist and the deploy should succeed.
