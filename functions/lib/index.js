"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOverdueHomeworkNotifications = exports.sendSessionReminders = exports.sendNotificationOnCreate = exports.updateUserPassword = exports.deleteStudent = exports.createParent = exports.createStudent = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const STUDENT_EMAIL_DOMAIN = "polenacademy.com";
function toEmailLocalPart(firstName, lastName) {
    var _a;
    const combined = `${(firstName || "").trim()}${(lastName || "").trim()}`.toLowerCase();
    const map = {
        "ğ": "g", "ü": "u", "ş": "s", "ö": "o", "ç": "c", "ı": "i", "İ": "i",
    };
    let out = "";
    for (const c of combined) {
        out += (_a = map[c]) !== null && _a !== void 0 ? _a : c;
    }
    out = out.replace(/[^a-z0-9]/g, "");
    return out || "student";
}
function generatePassword(length = 12) {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let result = "";
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}
/**
 * Creates a student user. Writes to Firestore with all Student properties:
 * uid, studentName, studentSurname, email, studentClass, coachId, parentId, progress, role, createdAt.
 */
exports.createStudent = functions
    .region("us-central1")
    .https.onCall(async (data, context) => {
    var _a, _b, _c, _d, _e, _f;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
    }
    const coachUid = context.auth.uid;
    // Flutter tarafında StudentModel.toMap ile gelen alanlar
    const rawStudentName = ((_a = data.studentName) !== null && _a !== void 0 ? _a : "");
    const rawStudentSurname = ((_b = data.studentSurname) !== null && _b !== void 0 ? _b : "");
    const rawStudentClass = ((_c = data.studentClass) !== null && _c !== void 0 ? _c : "");
    const rawCoachId = ((_d = data.coachId) !== null && _d !== void 0 ? _d : "");
    const rawParentId = ((_e = data.parentId) !== null && _e !== void 0 ? _e : "");
    const rawProgress = data.progress;
    const rawFocusCourseIds = data.focusCourseIds;
    const rawAcademicField = data.academicField;
    const studentName = rawStudentName.trim();
    const studentSurname = rawStudentSurname.trim();
    const studentClass = rawStudentClass.trim();
    if (!studentName || !studentSurname || !studentClass) {
        throw new functions.https.HttpsError("invalid-argument", "studentName, studentSurname and studentClass are required.");
    }
    const db = admin.firestore();
    const auth = admin.auth();
    const coachDoc = await db.collection("Users").doc(coachUid).get();
    const coachRole = (_f = coachDoc.data()) === null || _f === void 0 ? void 0 : _f.role;
    if (coachRole !== "coach") {
        throw new functions.https.HttpsError("permission-denied", "Only coaches can create students.");
    }
    // E-posta üretimi
    const baseLocal = toEmailLocalPart(studentName, studentSurname);
    let localPart = baseLocal;
    let suffix = 0;
    let email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;
    let usersSnap = await db
        .collection("Users")
        .where("email", "==", email)
        .limit(1)
        .get();
    while (!usersSnap.empty) {
        suffix++;
        localPart = `${baseLocal}${suffix}`;
        email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;
        usersSnap = await db
            .collection("Users")
            .where("email", "==", email)
            .limit(1)
            .get();
    }
    const password = generatePassword(12);
    const userRecord = await auth.createUser({
        email,
        password,
        emailVerified: false,
    });
    const uid = userRecord.uid;
    const finalCoachId = rawCoachId || coachUid;
    const finalParentId = rawParentId || "";
    const focusIds = Array.isArray(rawFocusCourseIds)
        ? rawFocusCourseIds
            .map((id) => String(id))
            .filter(Boolean)
        : [];
    const userData = {
        uid,
        studentName,
        studentSurname,
        email,
        studentClass,
        coachId: finalCoachId,
        parentId: finalParentId,
        role: "student",
        progress: typeof rawProgress === "number" ? rawProgress : 0,
        hasParent: !!finalParentId,
        focusCourseIds: focusIds,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const academicField = typeof rawAcademicField === "string" ? rawAcademicField.trim() : "";
    if (academicField !== "") {
        userData.academicField = academicField;
    }
    await db.collection("Users").doc(uid).set(userData);
    return { email, password, uid };
});
var createParent_1 = require("./createParent");
Object.defineProperty(exports, "createParent", { enumerable: true, get: function () { return createParent_1.createParent; } });
var deleteStudent_1 = require("./deleteStudent");
Object.defineProperty(exports, "deleteStudent", { enumerable: true, get: function () { return deleteStudent_1.deleteStudent; } });
var updateUserPassword_1 = require("./updateUserPassword");
Object.defineProperty(exports, "updateUserPassword", { enumerable: true, get: function () { return updateUserPassword_1.updateUserPassword; } });
var sendNotificationOnCreate_1 = require("./sendNotificationOnCreate");
Object.defineProperty(exports, "sendNotificationOnCreate", { enumerable: true, get: function () { return sendNotificationOnCreate_1.sendNotificationOnCreate; } });
var sendSessionReminders_1 = require("./sendSessionReminders");
Object.defineProperty(exports, "sendSessionReminders", { enumerable: true, get: function () { return sendSessionReminders_1.sendSessionReminders; } });
var sendOverdueHomeworkNotifications_1 = require("./sendOverdueHomeworkNotifications");
Object.defineProperty(exports, "sendOverdueHomeworkNotifications", { enumerable: true, get: function () { return sendOverdueHomeworkNotifications_1.sendOverdueHomeworkNotifications; } });
//# sourceMappingURL=index.js.map