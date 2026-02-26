import 'package:get_it/get_it.dart';
import 'package:polen_academy/data/auth/repository/auth_repository_impl.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/data/curriculum/repository/curriculum_repository_impl.dart';
import 'package:polen_academy/data/curriculum/source/curriculum_firebase_service.dart';
import 'package:polen_academy/data/goals/repository/goals_repository_impl.dart';
import 'package:polen_academy/data/goals/source/goals_firebase_service.dart';
import 'package:polen_academy/data/homework/repository/homework_repository_impl.dart';
import 'package:polen_academy/data/homework/repository/homework_submission_repository_impl.dart';
import 'package:polen_academy/data/homework/source/homework_firebase_service.dart';
import 'package:polen_academy/data/homework/source/homework_storage_service.dart';
import 'package:polen_academy/data/homework/source/homework_submission_firebase_service.dart';
import 'package:polen_academy/data/notification/repository/notification_repository_impl.dart';
import 'package:polen_academy/data/notification/source/notification_firebase_service.dart';
import 'package:polen_academy/data/session/repository/session_repository_impl.dart';
import 'package:polen_academy/data/session/source/session_firebase_service.dart';
import 'package:polen_academy/data/user/repository/user_repository_impl.dart';
import 'package:polen_academy/data/user/source/user_firebase_service.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signin.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signup.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signin.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signup.dart';
import 'package:polen_academy/domain/auth/usecases/student_signin.dart';
import 'package:polen_academy/domain/auth/usecases/student_signup.dart';
import 'package:polen_academy/domain/curriculum/repository/curriculum_repository.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';
import 'package:polen_academy/domain/goals/usecases/get_student_topic_progress.dart';
import 'package:polen_academy/domain/goals/usecases/revert_topic_progress_for_homework.dart';
import 'package:polen_academy/domain/goals/usecases/sync_topic_progress_from_homework.dart';
import 'package:polen_academy/domain/goals/usecases/update_topic_progress.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/create_homework.dart';
import 'package:polen_academy/domain/homework/usecases/delete_homework.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/get_overdue_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/homework/usecases/add_uploaded_url_to_submission.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/homework/usecases/upload_homework_file.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/domain/session/usecases/create_session.dart';
import 'package:polen_academy/domain/session/usecases/delete_session.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_student_and_date.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_student_and_date_range.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/domain/notification/usecases/create_notifications.dart';
import 'package:polen_academy/domain/notification/usecases/get_notifications_for_user.dart';
import 'package:polen_academy/domain/notification/usecases/get_unread_notification_count.dart';
import 'package:polen_academy/domain/notification/usecases/mark_all_notifications_as_read.dart';
import 'package:polen_academy/domain/notification/usecases/mark_notification_as_read.dart';
import 'package:polen_academy/domain/notification/usecases/notify_homework_assigned.dart';
import 'package:polen_academy/domain/notification/usecases/notify_homework_completed_by_student.dart';
import 'package:polen_academy/domain/notification/usecases/notify_homework_status_by_coach.dart';
import 'package:polen_academy/domain/notification/usecases/notify_overdue_to_parent.dart';
import 'package:polen_academy/domain/notification/usecases/notify_session_planned.dart';
import 'package:polen_academy/domain/notification/usecases/notify_session_status.dart';
import 'package:polen_academy/domain/notification/usecases/schedule_session_reminder.dart';
import 'package:polen_academy/domain/session/usecases/update_session.dart';
import 'package:polen_academy/domain/session/usecases/update_session_status.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/domain/user/usecases/delete_student.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_parent_id.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_uid.dart';
import 'package:polen_academy/domain/user/usecases/update_user_password.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  // Services
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<UserFirebaseService>(UserFirebaseServiceImpl());
  sl.registerSingleton<SessionFirebaseService>(SessionFirebaseServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<UserRepository>(UserRepositoryImpl());
  sl.registerSingleton<SessionRepository>(SessionRepositoryImpl());
  sl.registerSingleton<CurriculumFirebaseService>(CurriculumFirebaseServiceImpl());
  sl.registerSingleton<CurriculumRepository>(CurriculumRepositoryImpl(sl()));
  sl.registerSingleton<GoalsFirebaseService>(GoalsFirebaseServiceImpl());
  sl.registerSingleton<GoalsRepository>(GoalsRepositoryImpl(sl()));
  sl.registerSingleton<HomeworkFirebaseService>(HomeworkFirebaseServiceImpl());
  sl.registerSingleton<HomeworkStorageService>(HomeworkStorageServiceImpl());
  sl.registerSingleton<HomeworkRepository>(HomeworkRepositoryImpl(sl()));
  sl.registerSingleton<HomeworkSubmissionFirebaseService>(HomeworkSubmissionFirebaseServiceImpl());
  sl.registerSingleton<HomeworkSubmissionRepository>(HomeworkSubmissionRepositoryImpl(sl()));
  sl.registerSingleton<NotificationFirebaseService>(NotificationFirebaseServiceImpl());
  sl.registerSingleton<NotificationRepository>(NotificationRepositoryImpl());

  // Auth Usecases
  sl.registerSingleton<CoachSignupUseCase>(CoachSignupUseCase());
  sl.registerSingleton<CoachSigninUseCase>(CoachSigninUseCase());
  sl.registerSingleton<StudentSignupUseCase>(StudentSignupUseCase());
  sl.registerSingleton<StudentSigninUseCase>(StudentSigninUseCase());
  sl.registerSingleton<ParentSignupUseCase>(ParentSignupUseCase());
  sl.registerSingleton<ParentSigninUseCase>(ParentSigninUseCase());
  sl.registerSingleton<SignoutUseCase>(SignoutUseCase());
  sl.registerSingleton<GetCurrentUserRoleUseCase>(GetCurrentUserRoleUseCase());

  // User Usecases
  sl.registerSingleton<GetMyStudentsUseCase>(GetMyStudentsUseCase());
  sl.registerSingleton<GetStudentByUidUseCase>(GetStudentByUidUseCase());
  sl.registerSingleton<GetStudentByParentIdUseCase>(GetStudentByParentIdUseCase());
  sl.registerSingleton<DeleteStudentUseCase>(DeleteStudentUseCase());
  sl.registerSingleton<UpdateUserPasswordUseCase>(UpdateUserPasswordUseCase());

  // Session Usecases
  sl.registerSingleton<GetSessionsByDateRangeUseCase>(GetSessionsByDateRangeUseCase());
  sl.registerSingleton<GetSessionsByDateUseCase>(GetSessionsByDateUseCase());
  sl.registerSingleton<GetSessionsByStudentAndDateRangeUseCase>(GetSessionsByStudentAndDateRangeUseCase());
  sl.registerSingleton<GetSessionsByStudentAndDateUseCase>(GetSessionsByStudentAndDateUseCase());
  sl.registerSingleton<CreateSessionUseCase>(CreateSessionUseCase());
  sl.registerSingleton<UpdateSessionUseCase>(UpdateSessionUseCase());
  sl.registerSingleton<DeleteSessionUseCase>(DeleteSessionUseCase());
  sl.registerSingleton<UpdateSessionStatusUseCase>(UpdateSessionStatusUseCase());

  // Curriculum & Goals Usecases
  sl.registerSingleton<GetCurriculumTreeUseCase>(GetCurriculumTreeUseCase());
  sl.registerSingleton<GetStudentTopicProgressUseCase>(GetStudentTopicProgressUseCase());
  sl.registerSingleton<UpdateTopicProgressUseCase>(UpdateTopicProgressUseCase());
  sl.registerSingleton<SyncTopicProgressFromHomeworkUseCase>(SyncTopicProgressFromHomeworkUseCase());
  sl.registerSingleton<RevertTopicProgressForHomeworkUseCase>(RevertTopicProgressForHomeworkUseCase());

  // Homework Usecases
  sl.registerSingleton<GetHomeworksByStudentAndDateRangeUseCase>(GetHomeworksByStudentAndDateRangeUseCase());
  sl.registerSingleton<CreateHomeworkUseCase>(CreateHomeworkUseCase());
  sl.registerSingleton<DeleteHomeworkUseCase>(DeleteHomeworkUseCase());
  sl.registerSingleton<GetCompletedHomeworksForCoachUseCase>(GetCompletedHomeworksForCoachUseCase());
  sl.registerSingleton<GetOverdueHomeworksForCoachUseCase>(GetOverdueHomeworksForCoachUseCase());
  sl.registerSingleton<AddUploadedUrlToSubmissionUseCase>(AddUploadedUrlToSubmissionUseCase());
  sl.registerSingleton<SetHomeworkSubmissionStatusUseCase>(SetHomeworkSubmissionStatusUseCase());
  sl.registerSingleton<UploadHomeworkFileUseCase>(UploadHomeworkFileUseCase());

  // Notification Usecases
  sl.registerSingleton<CreateNotificationsUseCase>(CreateNotificationsUseCase());
  sl.registerSingleton<GetNotificationsForUserUseCase>(GetNotificationsForUserUseCase());
  sl.registerSingleton<GetUnreadNotificationCountUseCase>(GetUnreadNotificationCountUseCase());
  sl.registerSingleton<MarkNotificationAsReadUseCase>(MarkNotificationAsReadUseCase());
  sl.registerSingleton<MarkAllNotificationsAsReadUseCase>(MarkAllNotificationsAsReadUseCase());
  sl.registerSingleton<NotifySessionPlannedUseCase>(NotifySessionPlannedUseCase());
  sl.registerSingleton<NotifySessionStatusUseCase>(NotifySessionStatusUseCase());
  sl.registerSingleton<ScheduleSessionReminderUseCase>(ScheduleSessionReminderUseCase());
  sl.registerSingleton<NotifyHomeworkAssignedUseCase>(NotifyHomeworkAssignedUseCase());
  sl.registerSingleton<NotifyHomeworkCompletedByStudentUseCase>(NotifyHomeworkCompletedByStudentUseCase());
  sl.registerSingleton<NotifyHomeworkStatusByCoachUseCase>(NotifyHomeworkStatusByCoachUseCase());
  sl.registerSingleton<NotifyOverdueToParentUseCase>(NotifyOverdueToParentUseCase());
}
