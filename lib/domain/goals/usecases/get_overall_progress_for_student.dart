import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/usecases/get_student_topic_progress.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrencinin genel ilerleme yüzdesini (konu tamamlanma) hesaplar. 0–100.
class GetOverallProgressForStudentUseCase {
  Future<int> call({StudentEntity? params}) async {
    if (params == null) return 0;
    final student = params;
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) return 0;
    final treeResult = await sl<GetCurriculumTreeUseCase>().call(params: classLevel);
    final progressResult = await sl<GetStudentTopicProgressUseCase>().call(params: student.uid);
    if (treeResult.isLeft() || progressResult.isLeft()) return 0;
    final tree = treeResult.fold((_) => null, (t) => t);
    if (tree == null) return 0;
    final progressMap = progressResult.fold((_) => <String, StudentTopicProgressEntity>{}, (m) => m);
    int totalTopics = 0, totalDone = 0;
    for (final courseWithUnits in tree.courses) {
      for (final unit in courseWithUnits.units) {
        for (final topic in unit.topics) {
          totalTopics++;
          final p = progressMap[topic.id];
          if (_isTopicCompleted(p)) totalDone++;
        }
      }
    }
    if (totalTopics == 0) return 0;
    return ((totalDone / totalTopics) * 100).round().clamp(0, 100);
  }

  static bool _isTopicCompleted(StudentTopicProgressEntity? p) {
    if (p == null) return false;
    if (p.konuStatus != TopicStatus.completed) return false;
    return p.revisionStatus == TopicStatus.completed || p.revisionStatus == TopicStatus.none;
  }
}
