/// Service لتحميل واسترجاع بيانات العمال
import '../models/worker_model.dart';

class WorkerService {
  /// تحميل قائمة العمال - يمكن استبدالها بـ API لاحقاً
  static Future<List<Worker>> fetchWorkers() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Worker(
        id: '1',
        name: 'أحمد محمد',
        category: 'كهربائي',
        city: 'الرياض',
        experience: 10,
        rating: 4.8,
        reviewsCount: 127,
        followersCount: 450,
        phone: '+966501234567',
        whatsapp: '+966501234567',
        imageUrl: 'https://i.pravatar.cc/300?img=12',
        portfolio: [
          'https://picsum.photos/400/300?random=1',
          'https://picsum.photos/400/300?random=2',
          'https://picsum.photos/400/300?random=3',
        ],
        bio: 'فني كهرباء متخصص بالأعمال المنزلية والتجارية، خبرة 10 سنوات',
        reviews: [],
      ),
      Worker(
        id: '2',
        name: 'محمود علي',
        category: 'نجار',
        city: 'جدة',
        experience: 8,
        rating: 4.6,
        reviewsCount: 95,
        followersCount: 320,
        phone: '+966501234568',
        whatsapp: '+966501234568',
        imageUrl: 'https://i.pravatar.cc/300?img=13',
        portfolio: [
          'https://picsum.photos/400/300?random=4',
          'https://picsum.photos/400/300?random=5',
        ],
        bio: 'نجار متخصص في الأثاث والديكور، جودة عالية وأسعار مناسبة',
        reviews: [],
      ),
      Worker(
        id: '3',
        name: 'سارة حسن',
        category: 'دهان',
        city: 'الدمام',
        experience: 6,
        rating: 4.9,
        reviewsCount: 156,
        followersCount: 580,
        phone: '+966501234569',
        whatsapp: '+966501234569',
        imageUrl: 'https://i.pravatar.cc/300?img=47',
        portfolio: [
          'https://picsum.photos/400/300?random=6',
          'https://picsum.photos/400/300?random=7',
          'https://picsum.photos/400/300?random=8',
        ],
        bio: 'معالجة دهانات احترافية بأنواع دهانات عالية الجودة',
        reviews: [],
      ),
      Worker(
        id: '4',
        name: 'عمر فهد',
        category: 'سباك',
        city: 'الرياض',
        experience: 12,
        rating: 4.7,
        reviewsCount: 203,
        followersCount: 720,
        phone: '+966501234570',
        whatsapp: '+966501234570',
        imageUrl: 'https://i.pravatar.cc/300?img=33',
        portfolio: [
          'https://picsum.photos/400/300?random=9',
          'https://picsum.photos/400/300?random=10',
        ],
        bio: 'سباك متخصص بالصيانة والتركيبات الحديثة، خبرة 12 سنة',
        reviews: [],
      ),
      Worker(
        id: '5',
        name: 'فاطمة خالد',
        category: 'حداد',
        city: 'الرياض',
        experience: 7,
        rating: 4.5,
        reviewsCount: 78,
        followersCount: 250,
        phone: '+966501234571',
        whatsapp: '+966501234571',
        imageUrl: 'https://i.pravatar.cc/300?img=48',
        portfolio: [
          'https://picsum.photos/400/300?random=11',
          'https://picsum.photos/400/300?random=12',
        ],
        bio: 'حدادة متخصصة بأعمال الحديد والألمنيوم الحديثة',
        reviews: [],
      ),
      Worker(
        id: '6',
        name: 'خالد يوسف',
        category: 'بناء',
        city: 'جدة',
        experience: 15,
        rating: 4.8,
        reviewsCount: 289,
        followersCount: 950,
        phone: '+966501234572',
        whatsapp: '+966501234572',
        imageUrl: 'https://i.pravatar.cc/300?img=23',
        portfolio: [
          'https://picsum.photos/400/300?random=13',
          'https://picsum.photos/400/300?random=14',
          'https://picsum.photos/400/300?random=15',
        ],
        bio: 'مقاول بناء متخصص بالمشاريع السكنية والتجارية الكبرى',
        reviews: [],
      ),
    ];
  }

  /// البحث عن عامل من خلال الاسم أو المدينة أو التخصص
  static List<Worker> searchWorkers(List<Worker> workers, String query) {
    if (query.isEmpty) return workers;

    return workers.where((worker) {
      return worker.name.toLowerCase().contains(query.toLowerCase()) ||
          worker.city.toLowerCase().contains(query.toLowerCase()) ||
          worker.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// تصفية العمال حسب التخصص
  static List<Worker> filterByCategory(List<Worker> workers, String category) {
    if (category == 'الكل') return workers;
    return workers.where((worker) => worker.category == category).toList();
  }

  /// الحصول على أفضل العمال (أعلى تقييم وأكثر متابعة)
  static List<Worker> getTopWorkers(List<Worker> workers, {int limit = 5}) {
    final sorted = List<Worker>.from(workers);
    sorted.sort((a, b) {
      // ترتيب حسب التقييم أولاً، ثم حسب عدد المتابعين
      if (b.rating != a.rating) {
        return b.rating.compareTo(a.rating);
      }
      return b.followersCount.compareTo(a.followersCount);
    });
    return sorted.take(limit).toList();
  }
}
