class FitnessTip {
  final String id;
  final String title;
  final String description;
  final String category; // 'bodybuilding', 'weight_loss', 'general_health', 'endurance'
  final List<String> foods;
  final List<String> exercises;
  final List<String> lifestyleTips;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'

  FitnessTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.foods,
    required this.exercises,
    required this.lifestyleTips,
    required this.difficulty,
  });
}

class FitnessTipsData {
  static List<FitnessTip> getBodybuildingTips() {
    return [
      FitnessTip(
        id: 'bb1',
        title: 'Muscle Building Fundamentals',
        description: 'Essential principles for building muscle mass and strength',
        category: 'bodybuilding',
        foods: [
          'Lean proteins (chicken, fish, eggs)',
          'Complex carbohydrates (brown rice, sweet potatoes)',
          'Healthy fats (avocados, nuts, olive oil)',
          'Protein shakes and supplements',
          'Greek yogurt and cottage cheese'
        ],
        exercises: [
          'Compound movements (squats, deadlifts, bench press)',
          'Progressive overload training',
          '8-12 rep range for hypertrophy',
          'Rest days for muscle recovery',
          'Consistent training schedule'
        ],
        lifestyleTips: [
          'Get 7-9 hours of quality sleep',
          'Stay hydrated (3-4 liters daily)',
          'Eat in a slight caloric surplus',
          'Track your progress consistently',
          'Manage stress levels'
        ],
        difficulty: 'intermediate',
      ),
      FitnessTip(
        id: 'bb2',
        title: 'Advanced Bodybuilding Techniques',
        description: 'Advanced strategies for experienced lifters',
        category: 'bodybuilding',
        foods: [
          'BCAA supplements',
          'Creatine monohydrate',
          'Pre-workout formulas',
          'Post-workout protein timing',
          'Meal frequency optimization'
        ],
        exercises: [
          'Drop sets and supersets',
          'Pyramid training',
          'Isolation exercises',
          'Mind-muscle connection focus',
          'Variation in training splits'
        ],
        lifestyleTips: [
          'Periodization in training',
          'Recovery optimization',
          'Advanced nutrition timing',
          'Supplement cycling',
          'Professional guidance'
        ],
        difficulty: 'advanced',
      ),
    ];
  }

  static List<FitnessTip> getWeightLossTips() {
    return [
      FitnessTip(
        id: 'wl1',
        title: 'Sustainable Weight Loss',
        description: 'Healthy and maintainable weight loss strategies',
        category: 'weight_loss',
        foods: [
          'High-fiber vegetables',
          'Lean protein sources',
          'Whole grains in moderation',
          'Healthy fats for satiety',
          'Low-calorie dense foods'
        ],
        exercises: [
          'Cardio (walking, cycling, swimming)',
          'Strength training for metabolism',
          'High-intensity interval training',
          'Daily movement and activity',
          'Consistent exercise routine'
        ],
        lifestyleTips: [
          'Create a caloric deficit',
          'Mindful eating practices',
          'Regular meal timing',
          'Adequate sleep (7-8 hours)',
          'Stress management'
        ],
        difficulty: 'beginner',
      ),
    ];
  }

  static List<FitnessTip> getGeneralHealthTips() {
    return [
      FitnessTip(
        id: 'gh1',
        title: 'Overall Wellness',
        description: 'Comprehensive health and fitness for everyone',
        category: 'general_health',
        foods: [
          'Balanced macronutrients',
          'Colorful fruits and vegetables',
          'Whole foods over processed',
          'Adequate protein intake',
          'Healthy hydration habits'
        ],
        exercises: [
          '150 minutes moderate cardio weekly',
          'Strength training 2-3 times weekly',
          'Flexibility and mobility work',
          'Balance and coordination exercises',
          'Regular physical activity'
        ],
        lifestyleTips: [
          'Maintain healthy sleep schedule',
          'Manage stress effectively',
          'Regular health check-ups',
          'Social connections and support',
          'Lifelong learning mindset'
        ],
        difficulty: 'beginner',
      ),
    ];
  }

  static List<FitnessTip> getEnduranceTips() {
    return [
      FitnessTip(
        id: 'en1',
        title: 'Endurance Building',
        description: 'Improve cardiovascular fitness and stamina',
        category: 'endurance',
        foods: [
          'Complex carbohydrates for energy',
          'Electrolyte-rich foods',
          'Adequate protein for recovery',
          'Hydration optimization',
          'Energy gels for long sessions'
        ],
        exercises: [
          'Progressive distance training',
          'Interval training variations',
          'Cross-training activities',
          'Recovery runs and sessions',
          'Consistent training volume'
        ],
        lifestyleTips: [
          'Gradual progression in training',
          'Proper recovery protocols',
          'Nutrition timing strategies',
          'Mental toughness development',
          'Goal setting and tracking'
        ],
        difficulty: 'intermediate',
      ),
    ];
  }
}
