import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/student/student_helper.dart';
import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/service_locator.dart';

class AddStudentSection {
  AddStudentSection({required this.title, required this.courses});

  final String title;
  final List<CourseEntity> courses;
}

class AddStudentFormState {
  const AddStudentFormState({
    this.firstName = '',
    this.lastName = '',
    this.selectedClass = 'Bir sınıf seçin',
    this.selectedAcademicField = 'Alan Seçilmedi',
    this.sections = const [],
    this.enabledExamSections = const {},
    this.selectedCourseIds = const {},
    this.loadingCourses = false,
  });

  final String firstName;
  final String lastName;
  final String selectedClass;
  final String selectedAcademicField;
  final List<AddStudentSection> sections;
  final Set<String> enabledExamSections;
  final Set<String> selectedCourseIds;
  final bool loadingCourses;

  AddStudentFormState copyWith({
    String? firstName,
    String? lastName,
    String? selectedClass,
    String? selectedAcademicField,
    List<AddStudentSection>? sections,
    Set<String>? enabledExamSections,
    Set<String>? selectedCourseIds,
    bool? loadingCourses,
  }) {
    return AddStudentFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedAcademicField: selectedAcademicField ?? this.selectedAcademicField,
      sections: sections ?? this.sections,
      enabledExamSections: enabledExamSections ?? this.enabledExamSections,
      selectedCourseIds: selectedCourseIds ?? this.selectedCourseIds,
      loadingCourses: loadingCourses ?? this.loadingCourses,
    );
  }
}

class AddStudentFormCubit extends Cubit<AddStudentFormState> {
  AddStudentFormCubit() : super(const AddStudentFormState()) {
    loadCoursesForClass();
  }

  void setFirstName(String value) =>
      emit(state.copyWith(firstName: value));

  void setLastName(String value) =>
      emit(state.copyWith(lastName: value));

  void setClass(String value) {
    if (value == state.selectedClass) return;
    emit(state.copyWith(selectedClass: value));
    loadCoursesForClass();
  }

  void setAcademicField(String value) =>
      emit(state.copyWith(selectedAcademicField: value));

  // 11 / TYT / AYT / YDS anahtarları
  static String sectionKeyForTitle(String title) {
    if (title.startsWith('11. Sınıf')) return '11. Sınıf';
    if (title.startsWith('TYT')) return 'TYT';
    if (title.startsWith('AYT')) return 'AYT';
    if (title.startsWith('Dil (YDS)')) return 'YDS';
    return title;
  }

  Future<void> loadCoursesForClass() async {
    emit(state.copyWith(loadingCourses: true));
    final classLevel = state.selectedClass;
    if (classLevel == 'Bir sınıf seçin') {
      emit(state.copyWith(
        sections: const [],
        enabledExamSections: const {},
        selectedCourseIds: const {},
        loadingCourses: false,
      ));
      return;
    }
    final isExamClass = StudentHelper.isClassWithExamSections(classLevel);

    if (isExamClass) {
      final enabled = <String>{};
      final futures = <Future>[];
      final sections = <AddStudentSection>[];

      if (classLevel == '11. Sınıf') {
        enabled.addAll(['11. Sınıf', 'TYT']);
        futures.addAll([
          sl<GetCurriculumTreeUseCase>().call(params: '11. Sınıf'),
          sl<GetCurriculumTreeUseCase>().call(params: 'TYT'),
        ]);
        final results = await Future.wait(futures);
        results[0].fold(
          (_) {},
          (CurriculumTree tree) => sections.add(AddStudentSection(
            title: '11. Sınıf Dersleri',
            courses: tree.courses.map((c) => c.course).toList(),
          )),
        );
        results[1].fold(
          (_) {},
          (CurriculumTree tree) => sections.add(AddStudentSection(
            title: 'TYT Dersleri',
            courses: tree.courses.map((c) => c.course).toList(),
          )),
        );
      } else {
        // 12. sınıf veya Mezun
        enabled.addAll(['TYT', 'AYT', 'YDS']);
        futures.addAll([
          sl<GetCurriculumTreeUseCase>().call(params: 'TYT'),
          sl<GetCurriculumTreeUseCase>().call(params: 'AYT'),
          sl<GetCurriculumTreeUseCase>().call(params: 'YDS'),
        ]);
        final results = await Future.wait(futures);
        results[0].fold(
          (_) {},
          (CurriculumTree tree) => sections.add(AddStudentSection(
            title: 'TYT Dersleri',
            courses: tree.courses.map((c) => c.course).toList(),
          )),
        );
        results[1].fold(
          (_) {},
          (CurriculumTree tree) => sections.add(AddStudentSection(
            title: 'AYT Dersleri',
            courses: tree.courses.map((c) => c.course).toList(),
          )),
        );
        results[2].fold(
          (_) {},
          (CurriculumTree tree) => sections.add(AddStudentSection(
            title: 'Dil (YDS) Dersleri',
            courses: tree.courses.map((c) => c.course).toList(),
          )),
        );
      }

      _applySections(sections, enabled);
      return;
    }

    final result = await sl<GetCurriculumTreeUseCase>().call(params: classLevel);
    result.fold(
      (_) => _applySections([], state.enabledExamSections),
      (CurriculumTree tree) {
        final courses = tree.courses.map((c) => c.course).toList();
        _applySections(
          [AddStudentSection(title: '$classLevel Dersleri', courses: courses)],
          state.enabledExamSections,
        );
      },
    );
  }

  void _applySections(List<AddStudentSection> sections, Set<String> enabled) {
    final allIds = sections.expand((s) => s.courses.map((c) => c.id)).toSet();
    final filteredSelected = state.selectedCourseIds
        .where(allIds.contains)
        .toSet();
    emit(state.copyWith(
      sections: sections,
      enabledExamSections: enabled,
      loadingCourses: false,
      selectedCourseIds: filteredSelected,
    ));
  }

  void toggleExamSection(String key, bool enabled) {
    final newEnabled = Set<String>.from(state.enabledExamSections);
    if (enabled) {
      newEnabled.add(key);
    } else {
      newEnabled.remove(key);
      final sectionCourseIds = state.sections
          .where((s) => sectionKeyForTitle(s.title) == key)
          .expand((s) => s.courses)
          .map((c) => c.id)
          .toSet();
      final newSelected = state.selectedCourseIds
          .where((id) => !sectionCourseIds.contains(id))
          .toSet();
      emit(state.copyWith(
        enabledExamSections: newEnabled,
        selectedCourseIds: newSelected,
      ));
      return;
    }
    emit(state.copyWith(enabledExamSections: newEnabled));
  }

  void toggleCourse(String courseId, bool selected) {
    final set = Set<String>.from(state.selectedCourseIds);
    if (selected) {
      set.add(courseId);
    } else {
      set.remove(courseId);
    }
    emit(state.copyWith(selectedCourseIds: set));
  }
}

