import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/usecases/create_homework.dart';
import 'package:polen_academy/domain/homework/usecases/upload_homework_file.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/add_homework_state.dart';
import 'package:polen_academy/service_locator.dart';

class AddHomeworkCubit extends Cubit<AddHomeworkState> {
  AddHomeworkCubit({
    required this.student,
    required DateTime initialDate,
    required this.coachId,
  }) : super(AddHomeworkState(endDate: initialDate, assignedDate: initialDate, optionalTime: '23:59')) {
    _loadCurriculum();
  }

  final StudentEntity student;
  final String coachId;

  void _loadCurriculum() {
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) return;
    sl<GetCurriculumTreeUseCase>().call(params: classLevel).then((result) {
      result.fold(
        (_) => null,
        (tree) {
          final focusIds = student.focusCourseIds;
          final filteredTree = focusIds.isNotEmpty
              ? CurriculumTree(
                  courses: tree.courses.where((c) => focusIds.contains(c.course.id)).toList(),
                )
              : tree;
          emit(state.copyWith(curriculumTree: filteredTree));
        },
      );
    });
  }

  void setType(HomeworkType type) {
    emit(state.copyWith(
      type: type,
      routineInterval: type == HomeworkType.routine ? RoutineInterval.daily : null,
      courseId: type == HomeworkType.freeText ? null : state.courseId,
      topicIds: type == HomeworkType.freeText ? [] : state.topicIds,
    ));
  }

  void setStartDate(DateTime? date) => emit(state.copyWith(startDate: date));
  void setEndDate(DateTime date) => emit(state.copyWith(endDate: date));
  void setOptionalTime(String? time) => emit(state.copyWith(optionalTime: time));
  void setCourseId(String? id) => emit(state.copyWith(courseId: id));
  void setTopicIds(List<String> ids) => emit(state.copyWith(topicIds: ids));
  void toggleTopic(String topicId) {
    final list = List<String>.from(state.topicIds);
    if (list.contains(topicId)) {
      list.remove(topicId);
    } else {
      list.add(topicId);
    }
    emit(state.copyWith(topicIds: list));
  }
  void setDescription(String text) => emit(state.copyWith(description: text));
  void addLink(String link) => emit(state.copyWith(links: [...state.links, link]));
  void removeLink(int index) {
    final list = List<String>.from(state.links)..removeAt(index);
    emit(state.copyWith(links: list));
  }
  void setYoutubeUrls(List<String> urls) => emit(state.copyWith(youtubeUrls: urls));
  void addFileUrl(String url) => emit(state.copyWith(fileUrls: [...state.fileUrls, url]));
  void removeFileUrl(int index) {
    final list = List<String>.from(state.fileUrls)..removeAt(index);
    emit(state.copyWith(fileUrls: list));
  }
  void setFileUrls(List<String> urls) => emit(state.copyWith(fileUrls: urls));

  /// Dosyayı Storage'a yükler ve URL'yi listeye ekler. Hata olursa errorMessage set edilir, null döner.
  Future<String?> uploadAndAddFile(String filePath) async {
    final result = await sl<UploadHomeworkFileUseCase>().call(
      filePath: filePath,
      studentId: student.uid,
    );
    return result.fold(
      (error) {
        emit(state.copyWith(errorMessage: error));
        return null;
      },
      (url) {
        addFileUrl(url);
        return url;
      },
    );
  }

  /// Birden fazla dosyayı yükler; başta loading true, sonda false emit eder (LoadingOverlay için).
  Future<void> uploadFilesWithLoading(List<String> paths) async {
    if (paths.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));
    for (final path in paths) {
      final result = await sl<UploadHomeworkFileUseCase>().call(
        filePath: path,
        studentId: student.uid,
      );
      result.fold(
        (error) => emit(state.copyWith(errorMessage: error)),
        (url) => addFileUrl(url),
      );
      if (state.errorMessage != null) break;
    }
    emit(state.copyWith(loading: false));
  }

  void setGoalKonuStudied(bool v) => emit(state.copyWith(goalKonuStudied: v));
  void setGoalRevisionDone(bool v) => emit(state.copyWith(goalRevisionDone: v));
  void setGoalResourceSolve(bool v) => emit(state.copyWith(goalResourceSolve: v));
  void setRoutineInterval(RoutineInterval? v) => emit(state.copyWith(routineInterval: v));

  Future<bool> submit() async {
    if (state.description.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Açıklama giriniz.'));
      return false;
    }
    // Sadece konu seçimli ödevde ders zorunlu
    final noCourse = state.courseId == null || state.courseId!.trim().isEmpty;
    if (state.type == HomeworkType.topicBased && noCourse) {
      emit(state.copyWith(errorMessage: 'Konu seçimli ödev için ders seçiniz.'));
      return false;
    }
    final tree = state.curriculumTree;
    String? courseName;
    List<String> topicNames = [];
    if (state.type == HomeworkType.topicBased && tree != null && state.courseId != null) {
      for (final c in tree.courses) {
        if (c.course.id == state.courseId) {
          courseName = c.course.name;
          for (final u in c.units) {
            for (final t in u.topics) {
              if (state.topicIds.contains(t.id)) {
                topicNames.add(t.name);
              }
            }
          }
          break;
        }
      }
    }
    final start = state.startDate ?? state.endDate;
    final entity = HomeworkEntity(
      id: '',
      coachId: coachId,
      studentId: student.uid,
      type: state.type,
      startDate: start,
      endDate: state.endDate,
      assignedDate: state.assignedDate,
      optionalTime: state.optionalTime,
      courseId: state.courseId,
      courseName: courseName,
      topicIds: state.topicIds,
      topicNames: topicNames,
      description: state.description,
      links: state.links,
      youtubeUrls: state.youtubeUrls,
      fileUrls: state.fileUrls,
      goalKonuStudied: state.goalKonuStudied,
      goalRevisionDone: state.goalRevisionDone,
      goalResourceSolve: state.goalResourceSolve,
      routineInterval: state.routineInterval,
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(loading: true, errorMessage: null));
    final result = await sl<CreateHomeworkUseCase>().call(params: entity);
    return result.fold(
      (error) {
        emit(state.copyWith(loading: false, errorMessage: error));
        return false;
      },
      (_) {
        emit(state.copyWith(loading: false));
        return true;
      },
    );
  }
}
