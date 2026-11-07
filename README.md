# CampusCare - Campus Incident Reporting

Individual Assignment 2 · Flutter + Firebase.

Students submit incident reports with photos and track their resolution. Staff
review the queue and move reports through Submitted -> In Progress -> Resolved.

---

## Stack

| Concern | Choice |
|---|---|
| Auth | Firebase Authentication (email + password) |
| Database | Cloud Firestore (`users`, `reports`) |
| Photos | Firebase Storage (`reports/{uid}/...`) |
| State | **Cubit** (`flutter_bloc`) - `AuthCubit`, `ReportCubit`, `StaffCubit` |
| Images | `image_picker`, compressed on device before upload |

## Architecture

```
lib/
  core/       theme, colours, validators, status machine, date formatting
  models/     AppUser, Report, StatusEvent, enums
  services/   auth_service, report_service, storage_service   <- only code touching Firebase
  cubits/     auth/, reports/, staff/
  screens/    auth, home, report/, staff/, profile
  widgets/    status_chip, category_tile, report_card, empty_state, app_bottom_nav
```

**The one rule:** the UI never calls Firebase. Screens emit to a Cubit, the Cubit
calls a service, the service is the only layer that knows Firestore exists.

---

## Setup (do this once)

### 1. Firebase project
1. Create a project at console.firebase.google.com, e.g. `campuscare`.
2. Add an **Android** app with package name `com.campuscare.campus_incident`.
   (Check `android/app/build.gradle.kts` -> `applicationId` for the exact value.)
3. Enable **Authentication -> Sign-in method -> Email/Password**.
4. Create **Firestore Database** in production mode.

   > **No Storage, and no billing.** Firebase Storage requires the paid Blaze
   > plan for new projects. With the instructor's permission, photographs are
   > hosted on **Cloudinary** instead - free tier, no card. See
   > `lib/core/cloud_config.dart`.

### 2. FlutterFire CLI
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```
This **overwrites** `lib/firebase_options.dart` (which currently holds
placeholders) with real credentials.

### 3. Deploy the Firestore rules
```bash
firebase deploy --only firestore:rules
```
The rules live in `firebase/firestore.rules`. They are the access control - do
not skip this, and do not rely on the console defaults.

`firebase/storage.rules` is retained to document the original design but is not
deployed, because Storage is not enabled.

### 3b. Configure the image host (Cloudinary)
1. Create a free account at cloudinary.com.
2. Settings -> Upload -> Upload presets -> add a preset with
   **Signing Mode: Unsigned**.
3. Put the cloud name and preset name into `lib/core/cloud_config.dart`.

An *unsigned* preset is designed for client-side uploads, so the API secret
never enters the app. Without these two values, photo upload throws a clear
"Photo storage is not configured" error.

### 4. Run
```bash
flutter pub get
flutter run          # on an emulator or a physical device, NOT Chrome
```

---

## Roles

New sign-ups are always **students** - the Firestore rules enforce that, so the
client cannot mint a staff account.

To make a staff account:

1. Register normally in the app with the staff email.
2. In **Firestore -> `users` -> that uid**, set:
   - `role`: `"staff"`
   - `department`: e.g. `"Facilities"`
3. Sign out and sign in again (the role is read at sign-in).

Create **both accounts before recording the demo video**.

---

## Testing

```bash
flutter analyze     # must be clean
flutter test        # 22 tests: validators, status machine, report model
```

| File | Covers |
|---|---|
| `test/validators_test.dart` | every form rule, including the mismatched-password case |
| `test/status_machine_test.dart` | legal and illegal status transitions |
| `test/report_test.dart` | Firestore payload shape, server timestamps, denormalisation |

The pure logic (`validators`, `StatusMachine`, `Report.toCreateMap`) is
Firebase-free on purpose, so it tests without an emulator or a network.

---

## Access control - the bit to demonstrate

Three independent layers:

1. **Rules** reject a status write from a non-staff account, whatever the app
   sends. This is the real enforcement.
2. **Cubit** refuses the transition and surfaces a message.
3. **UI** hides the staff card and the Staff Queue tile.

To prove layer 1 live, use **Firestore -> Rules -> Rules Playground** (not the
data editor: the console bypasses rules with admin privileges, so it proves
nothing).

- Location `reports/<real report id>`, operation **update**, authenticated as the
  **student** uid, payload `{"status": "resolved"}` -> **denied**
- Same request as the **staff** uid -> **allowed**

---

## Known gaps / next steps

- [ ] Replace `lib/firebase_options.dart` via `flutterfire configure`
- [ ] Deploy `firebase/firestore.rules` and `firebase/storage.rules`
- [ ] Polish UI against the Figma design
- [ ] Add a loading skeleton for the reports list
- [ ] Record the 7-10 minute demo (student flow, then staff status update)
- [ ] Write the technical report (APA/IEEE) with architecture diagram + screenshots


# Author - Robert Niyonkuru
