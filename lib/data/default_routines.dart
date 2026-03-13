import '../models/routine.dart';
import '../models/exercise.dart';

class DefaultRoutines {
  static List<Routine> get all => [
        _fuerzaBasica,
        _cardioHiit,
        _gluteosYPiernas,
        _espaldaBiceps,
        _fullBodyExpress,
        _yogaMananero,
        _movilidadStretching,
        _powerliftingPesado,
      ];

  static final _fuerzaBasica = Routine(
    id: 'default_001',
    name: 'Fuerza Básica',
    description: 'Rutina clásica de empuje para pecho, hombros y tríceps',
    type: 'strength',
    emoji: '💪',
    estimatedMinutes: 50,
    difficulty: 'Intermedio',
    isDefault: true,
    exercises: [
      Exercise(id: 'e001', name: 'Press de Banca', muscleGroup: 'Pecho', description: 'Acostado en banco, baja la barra al pecho', equipment: 'Barra', defaultSets: 4, defaultReps: 8, defaultWeight: 60, restSeconds: 90),
      Exercise(id: 'e002', name: 'Press Inclinado con Mancuernas', muscleGroup: 'Pecho', description: 'Banco inclinado 45°, mancuernas subidas en arco', equipment: 'Mancuernas', defaultSets: 3, defaultReps: 10, defaultWeight: 22, restSeconds: 75),
      Exercise(id: 'e003', name: 'Press Militar', muscleGroup: 'Hombros', description: 'De pie, barra desde el pecho hacia arriba', equipment: 'Barra', defaultSets: 4, defaultReps: 8, defaultWeight: 40, restSeconds: 90),
      Exercise(id: 'e004', name: 'Elevaciones Laterales', muscleGroup: 'Hombros', description: 'Brazos al costado, eleva hasta la altura del hombro', equipment: 'Mancuernas', defaultSets: 3, defaultReps: 15, defaultWeight: 8, restSeconds: 60),
      Exercise(id: 'e005', name: 'Extensiones de Tríceps', muscleGroup: 'Tríceps', description: 'Con polea alta, extiende los brazos hacia abajo', equipment: 'Polea', defaultSets: 3, defaultReps: 12, defaultWeight: 20, restSeconds: 60),
      Exercise(id: 'e006', name: 'Fondos en Paralelas', muscleGroup: 'Tríceps', description: 'En paralelas, baja el cuerpo con los codos cerca', equipment: 'Paralelas', defaultSets: 3, defaultReps: 12, defaultWeight: 0, restSeconds: 60),
    ],
  );

  static final _cardioHiit = Routine(
    id: 'default_002',
    name: 'Cardio HIIT 20min',
    description: 'Quema grasa intensa con intervalos de alta intensidad',
    type: 'hiit',
    emoji: '🔥',
    estimatedMinutes: 25,
    difficulty: 'Avanzado',
    isDefault: true,
    exercises: [
      Exercise(id: 'e010', name: 'Burpees', muscleGroup: 'Full Body', description: '4 tiempos: baja, plancha, levanta, salta', equipment: 'Cuerpo', defaultSets: 4, defaultReps: 15, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e011', name: 'Mountain Climbers', muscleGroup: 'Core', description: 'En plancha alta, alterna rodillas al pecho rápido', equipment: 'Cuerpo', defaultSets: 4, defaultReps: 30, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e012', name: 'Jumping Jacks', muscleGroup: 'Cardio', description: 'Salta abriendo piernas y brazos simultáneamente', equipment: 'Cuerpo', defaultSets: 4, defaultReps: 40, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e013', name: 'High Knees', muscleGroup: 'Cardio', description: 'Corre en el lugar levantando rodillas al pecho', equipment: 'Cuerpo', defaultSets: 4, defaultReps: 40, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e014', name: 'Jump Squats', muscleGroup: 'Piernas', description: 'Sentadilla profunda con salto explosivo al subir', equipment: 'Cuerpo', defaultSets: 3, defaultReps: 20, defaultWeight: 0, restSeconds: 40),
    ],
  );

  static final _gluteosYPiernas = Routine(
    id: 'default_003',
    name: 'Glúteos & Piernas',
    description: 'Tren inferior completo con énfasis en glúteos',
    type: 'strength',
    emoji: '🍑',
    estimatedMinutes: 55,
    difficulty: 'Intermedio',
    isDefault: true,
    exercises: [
      Exercise(id: 'e020', name: 'Sentadilla con Barra', muscleGroup: 'Piernas', description: 'Barra en hombros, baja hasta paralelo al suelo', equipment: 'Barra', defaultSets: 4, defaultReps: 8, defaultWeight: 70, restSeconds: 90),
      Exercise(id: 'e021', name: 'Hip Thrust', muscleGroup: 'Glúteos', description: 'Hombros en banco, barra en cadera, empuja hacia arriba', equipment: 'Barra + Banco', defaultSets: 4, defaultReps: 12, defaultWeight: 60, restSeconds: 75),
      Exercise(id: 'e022', name: 'Prensa de Piernas', muscleGroup: 'Piernas', description: 'Pies altos en la plataforma para énfasis en glúteos', equipment: 'Máquina', defaultSets: 3, defaultReps: 15, defaultWeight: 80, restSeconds: 75),
      Exercise(id: 'e023', name: 'Lunges Alternos', muscleGroup: 'Piernas', description: 'Zancadas largas alternando piernas', equipment: 'Mancuernas', defaultSets: 3, defaultReps: 12, defaultWeight: 15, restSeconds: 60),
      Exercise(id: 'e024', name: 'Extensiones de Cadera', muscleGroup: 'Glúteos', description: 'En máquina o con cable en polea baja', equipment: 'Cable', defaultSets: 3, defaultReps: 15, defaultWeight: 20, restSeconds: 60),
      Exercise(id: 'e025', name: 'Pantorrillas de Pie', muscleGroup: 'Piernas', description: 'Sube en puntillas, lento y controlado', equipment: 'Máquina', defaultSets: 4, defaultReps: 20, defaultWeight: 40, restSeconds: 45),
    ],
  );

  static final _espaldaBiceps = Routine(
    id: 'default_004',
    name: 'Espalda & Bíceps',
    description: 'Tirón vertical y horizontal para una espalda ancha',
    type: 'strength',
    emoji: '🦾',
    estimatedMinutes: 50,
    difficulty: 'Intermedio',
    isDefault: true,
    exercises: [
      Exercise(id: 'e030', name: 'Dominadas', muscleGroup: 'Espalda', description: 'Agarre prono, sube hasta que el mentón supere la barra', equipment: 'Barra', defaultSets: 4, defaultReps: 8, defaultWeight: 0, restSeconds: 90),
      Exercise(id: 'e031', name: 'Remo con Barra', muscleGroup: 'Espalda', description: 'Inclinado hacia adelante, lleva barra al abdomen', equipment: 'Barra', defaultSets: 4, defaultReps: 10, defaultWeight: 50, restSeconds: 90),
      Exercise(id: 'e032', name: 'Jalón al Pecho', muscleGroup: 'Espalda', description: 'En polea alta, lleva la barra hasta la clavícula', equipment: 'Polea', defaultSets: 3, defaultReps: 12, defaultWeight: 55, restSeconds: 75),
      Exercise(id: 'e033', name: 'Remo en Máquina', muscleGroup: 'Espalda', description: 'Pecho apoyado, tira de los mangos hacia los lados', equipment: 'Máquina', defaultSets: 3, defaultReps: 12, defaultWeight: 40, restSeconds: 60),
      Exercise(id: 'e034', name: 'Curl Bíceps con Barra', muscleGroup: 'Bíceps', description: 'Codos pegados al cuerpo, curla la barra hacia el pecho', equipment: 'Barra', defaultSets: 3, defaultReps: 12, defaultWeight: 30, restSeconds: 60),
      Exercise(id: 'e035', name: 'Curl Martillo', muscleGroup: 'Bíceps', description: 'Mancuernas verticales, curla alternando brazos', equipment: 'Mancuernas', defaultSets: 3, defaultReps: 12, defaultWeight: 12, restSeconds: 60),
    ],
  );

  static final _fullBodyExpress = Routine(
    id: 'default_005',
    name: 'Full Body Express',
    description: 'Entrena todo el cuerpo en menos de 40 minutos',
    type: 'strength',
    emoji: '⚡',
    estimatedMinutes: 35,
    difficulty: 'Principiante',
    isDefault: true,
    exercises: [
      Exercise(id: 'e040', name: 'Sentadilla con Peso Corporal', muscleGroup: 'Piernas', description: 'Pies al ancho de hombros, baja y sube controlado', equipment: 'Cuerpo', defaultSets: 3, defaultReps: 15, defaultWeight: 0, restSeconds: 60),
      Exercise(id: 'e041', name: 'Flexiones de Pecho', muscleGroup: 'Pecho', description: 'Cuerpo en línea recta, baja el pecho al suelo', equipment: 'Cuerpo', defaultSets: 3, defaultReps: 12, defaultWeight: 0, restSeconds: 60),
      Exercise(id: 'e042', name: 'Remo con Banda Elástica', muscleGroup: 'Espalda', description: 'Banda anclada, jala los codos hacia atrás', equipment: 'Banda', defaultSets: 3, defaultReps: 15, defaultWeight: 0, restSeconds: 60),
      Exercise(id: 'e043', name: 'Plancha', muscleGroup: 'Core', description: 'Mantén el cuerpo recto sobre los antebrazos', equipment: 'Cuerpo', defaultSets: 3, defaultReps: 1, defaultWeight: 0, restSeconds: 60),
      Exercise(id: 'e044', name: 'Zancadas en el Lugar', muscleGroup: 'Piernas', description: 'Alternando piernas sin desplazarte', equipment: 'Cuerpo', defaultSets: 3, defaultReps: 20, defaultWeight: 0, restSeconds: 60),
    ],
  );

  static final _yogaMananero = Routine(
    id: 'default_006',
    name: 'Yoga Mañanero',
    description: 'Activa el cuerpo y la mente con posturas suaves',
    type: 'yoga',
    emoji: '🧘',
    estimatedMinutes: 30,
    difficulty: 'Principiante',
    isDefault: true,
    exercises: [
      Exercise(id: 'e050', name: 'Saludo al Sol A', muscleGroup: 'Full Body', description: 'Fluye suavemente por 5 posturas en 5 respiraciones', equipment: 'Mat', defaultSets: 3, defaultReps: 5, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e051', name: 'Guerrero I', muscleGroup: 'Piernas', description: 'Sostén 5 respiraciones por lado, abre el pecho', equipment: 'Mat', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e052', name: 'Postura del Perro Boca Abajo', muscleGroup: 'Full Body', description: '10 respiraciones lentas, talones hacia el suelo', equipment: 'Mat', defaultSets: 3, defaultReps: 1, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e053', name: 'Postura del Niño', muscleGroup: 'Espalda', description: 'Relaja completamente la espalda y caderas', equipment: 'Mat', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 30),
      Exercise(id: 'e054', name: 'Torsión Espinal Sentado', muscleGroup: 'Core', description: 'Gira la columna suavemente a ambos lados', equipment: 'Mat', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 20),
    ],
  );

  static final _movilidadStretching = Routine(
    id: 'default_007',
    name: 'Movilidad & Stretching',
    description: 'Mejora tu rango de movimiento y recuperación',
    type: 'flexibility',
    emoji: '🤸',
    estimatedMinutes: 25,
    difficulty: 'Principiante',
    isDefault: true,
    exercises: [
      Exercise(id: 'e060', name: 'Apertura de Cadera 90/90', muscleGroup: 'Glúteos', description: 'Siéntate con las rodillas en 90°, inclínate adelante', equipment: 'Mat', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e061', name: 'Estiramiento de Paloma', muscleGroup: 'Glúteos', description: 'Pierna delantera cruzada en 90°, extiende la trasera', equipment: 'Mat', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e062', name: 'Giro Torácico', muscleGroup: 'Espalda', description: 'En cuadrupedia, lleva un brazo al cielo rotando', equipment: 'Mat', defaultSets: 2, defaultReps: 10, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e063', name: 'Estiramiento de Isquios', muscleGroup: 'Piernas', description: 'De pie, pierna extendida en un banco o escalón', equipment: 'Banco', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 20),
      Exercise(id: 'e064', name: 'Estiramiento de Cuádriceps', muscleGroup: 'Piernas', description: 'De pie, sostén el tobillo detrás hacia el glúteo', equipment: 'Cuerpo', defaultSets: 2, defaultReps: 1, defaultWeight: 0, restSeconds: 20),
    ],
  );

  static final _powerliftingPesado = Routine(
    id: 'default_008',
    name: 'Powerlifting Pesado',
    description: 'Los 3 grandes levantamientos para máxima fuerza',
    type: 'strength',
    emoji: '🏋️',
    estimatedMinutes: 75,
    difficulty: 'Avanzado',
    isDefault: true,
    exercises: [
      Exercise(id: 'e070', name: 'Sentadilla Competitiva', muscleGroup: 'Piernas', description: 'Profundidad reglamentaria, pausa en el fondo', equipment: 'Barra', defaultSets: 5, defaultReps: 5, defaultWeight: 100, restSeconds: 180),
      Exercise(id: 'e071', name: 'Press de Banca Competitivo', muscleGroup: 'Pecho', description: 'Pausa en el pecho, press hasta extensión completa', equipment: 'Barra', defaultSets: 5, defaultReps: 5, defaultWeight: 80, restSeconds: 180),
      Exercise(id: 'e072', name: 'Peso Muerto Convencional', muscleGroup: 'Espalda', description: 'Pies al ancho de caderas, barra pegada a las espinillas', equipment: 'Barra', defaultSets: 4, defaultReps: 4, defaultWeight: 120, restSeconds: 240),
      Exercise(id: 'e073', name: 'Peso Muerto Rumano', muscleGroup: 'Piernas', description: 'Accesorio: trabajar isquios y cadena posterior', equipment: 'Barra', defaultSets: 3, defaultReps: 8, defaultWeight: 80, restSeconds: 120),
    ],
  );

  // All exercises library (for custom routine picker)
  static List<Exercise> get exerciseLibrary => [
        ..._fuerzaBasica.exercises,
        ..._cardioHiit.exercises,
        ..._gluteosYPiernas.exercises,
        ..._espaldaBiceps.exercises,
        ..._fullBodyExpress.exercises,
        ..._yogaMananero.exercises,
        ..._movilidadStretching.exercises,
        ..._powerliftingPesado.exercises,
        // Extra exercises
        Exercise(id: 'ex001', name: 'Cruce de Poleas', muscleGroup: 'Pecho', description: 'Poleas altas, cruza los brazos al frente', equipment: 'Polea', defaultSets: 3, defaultReps: 15, defaultWeight: 15),
        Exercise(id: 'ex002', name: 'Face Pull', muscleGroup: 'Hombros', description: 'Polea alta, jala hacia la cara con codos altos', equipment: 'Polea', defaultSets: 3, defaultReps: 15, defaultWeight: 12),
        Exercise(id: 'ex003', name: 'Abdominales en Polea', muscleGroup: 'Core', description: 'De rodillas, nuca con polea alta, contrae el core', equipment: 'Polea', defaultSets: 3, defaultReps: 15, defaultWeight: 20),
        Exercise(id: 'ex004', name: 'Russian Twists', muscleGroup: 'Core', description: 'Sentado en V, gira el tronco con peso', equipment: 'Disco', defaultSets: 3, defaultReps: 20, defaultWeight: 10),
        Exercise(id: 'ex005', name: 'Bicicleta Estacionaria', muscleGroup: 'Cardio', description: '20 minutos a ritmo moderado', equipment: 'Bici', defaultSets: 1, defaultReps: 1, defaultWeight: 0),
        Exercise(id: 'ex006', name: 'Remo en Máquina Ergométrica', muscleGroup: 'Cardio', description: '15 minutos con intervalos de intensidad', equipment: 'Remo', defaultSets: 1, defaultReps: 1, defaultWeight: 0),
        Exercise(id: 'ex007', name: 'Sentadilla Sumo', muscleGroup: 'Piernas', description: 'Pies muy abiertos y punta de pies hacia afuera', equipment: 'Barra', defaultSets: 3, defaultReps: 10, defaultWeight: 60),
        Exercise(id: 'ex008', name: 'Curl de Bíceps en Máquina', muscleGroup: 'Bíceps', description: 'Codos apoyados, movimiento aislado', equipment: 'Máquina', defaultSets: 3, defaultReps: 12, defaultWeight: 25),
        Exercise(id: 'ex009', name: 'Extensiones de Pierna', muscleGroup: 'Piernas', description: 'Aísla el cuádriceps', equipment: 'Máquina', defaultSets: 3, defaultReps: 15, defaultWeight: 30),
        Exercise(id: 'ex010', name: 'Curl Femoral', muscleGroup: 'Piernas', description: 'Aísla los isquiosurales', equipment: 'Máquina', defaultSets: 3, defaultReps: 15, defaultWeight: 25),
        Exercise(id: 'ex011', name: 'Superman', muscleGroup: 'Espalda', description: 'Boca abajo, eleva brazos y piernas simultáneamente', equipment: 'Mat', defaultSets: 3, defaultReps: 15, defaultWeight: 0),
        Exercise(id: 'ex012', name: 'Elevaciones de Talones Sentado', muscleGroup: 'Piernas', description: 'En máquina sentado, trabaja la pantorrilla interna', equipment: 'Máquina', defaultSets: 4, defaultReps: 20, defaultWeight: 25),
      ];
}
