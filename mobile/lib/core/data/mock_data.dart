import '../models/user_role.dart';

/// Central mock data repository.
/// Replace internals with API calls later — UI stays untouched.
class MockData {
  // ── Demo Users ──────────────────────────────────
  static const citizenUser = AppUser(
    id: 'c1',
    name: 'Abdhesh',
    phone: '9801234567',
    role: UserRole.citizen,
    location: 'Ward 1, Kathmandu',
    walletBalance: 8620,
    email: 'abdhesh@jansawa.np',
  );

  static const governmentUser = AppUser(
    id: 'g1',
    name: 'Admin Officer',
    phone: '9841000000',
    role: UserRole.government,
    location: 'Ministry of IT, Singha Durbar',
    email: 'admin@gov.np',
  );

  // ── Courses ─────────────────────────────────────
  static const courses = [
    Course(
      id: 'cr1',
      title: 'Basic Computer Skills',
      description: 'Learn essential computer skills including MS Office, email, and internet browsing.',
      instructor: 'Ram Sharma',
      duration: '4 weeks',
      level: 'Beginner',
      enrolledCount: 45,
    ),
    Course(
      id: 'cr2',
      title: 'Mobile Repair Training',
      description: 'Hands-on training for diagnosing and repairing smartphones and tablets.',
      instructor: 'Sita Thapa',
      duration: '6 weeks',
      level: 'Intermediate',
      enrolledCount: 32,
    ),
    Course(
      id: 'cr3',
      title: 'Tailoring & Sewing',
      description: 'Professional tailoring course covering measurement, cutting, and stitching.',
      instructor: 'Maya Gurung',
      duration: '8 weeks',
      level: 'Beginner',
      enrolledCount: 28,
    ),
    Course(
      id: 'cr4',
      title: 'Plumbing Essentials',
      description: 'Learn residential plumbing installation and maintenance.',
      instructor: 'Bikash KC',
      duration: '5 weeks',
      level: 'Beginner',
      enrolledCount: 19,
    ),
    Course(
      id: 'cr5',
      title: 'Electrical Wiring',
      description: 'Safe residential electrical wiring, circuit design, and troubleshooting.',
      instructor: 'Deepak Adhikari',
      duration: '6 weeks',
      level: 'Intermediate',
      enrolledCount: 22,
    ),
  ];

  // ── Service Providers ───────────────────────────
  static const providers = [
    ServiceProvider(
      id: 'p1',
      name: 'Hari Plumbing',
      service: 'Plumber',
      location: 'Kathmandu-3',
      rating: 4.5,
      phone: '+977-9801234567',
      isApproved: true,
      iconName: 'plumbing',
    ),
    ServiceProvider(
      id: 'p2',
      name: 'Shrestha Tutors',
      service: 'Tutor',
      location: 'Lalitpur-5',
      rating: 4.8,
      phone: '+977-9807654321',
      isApproved: true,
      iconName: 'book',
    ),
    ServiceProvider(
      id: 'p3',
      name: 'Sundar Tailoring',
      service: 'Tailor',
      location: 'Bhaktapur-2',
      rating: 4.2,
      phone: '+977-9812345678',
      isApproved: true,
      iconName: 'content_cut',
    ),
    ServiceProvider(
      id: 'p4',
      name: 'Bright Electric',
      service: 'Electrician',
      location: 'Kathmandu-7',
      rating: 4.6,
      phone: '+977-9823456789',
      isApproved: true,
      iconName: 'electrical_services',
    ),
    ServiceProvider(
      id: 'p5',
      name: 'Colour House',
      service: 'Painter',
      location: 'Lalitpur-10',
      rating: 4.1,
      phone: '+977-9834567890',
      isApproved: true,
      iconName: 'format_paint',
    ),
    ServiceProvider(
      id: 'p6',
      name: 'Clean Nepal',
      service: 'Cleaner',
      location: 'Kathmandu-12',
      rating: 4.3,
      phone: '+977-9845678901',
      isApproved: true,
      iconName: 'cleaning_services',
    ),
    // Pending approval providers
    ServiceProvider(
      id: 'p7',
      name: 'New Tiles Co.',
      service: 'Tiling',
      location: 'Pokhara-4',
      rating: 0,
      phone: '+977-9856789012',
      isApproved: false,
      iconName: 'grid_view',
    ),
    ServiceProvider(
      id: 'p8',
      name: 'Garden Pro',
      service: 'Gardener',
      location: 'Chitwan-2',
      rating: 0,
      phone: '+977-9867890123',
      isApproved: false,
      iconName: 'yard',
    ),
  ];

  // ── Bookings ────────────────────────────────────
  static const bookings = [
    Booking(
      id: 'b1',
      serviceName: 'Plumbing',
      providerName: 'Hari Plumbing',
      citizenName: 'Abdhesh',
      date: '2026-02-15',
      status: 'confirmed',
      amount: 1500,
    ),
    Booking(
      id: 'b2',
      serviceName: 'Tutoring',
      providerName: 'Shrestha Tutors',
      citizenName: 'Abdhesh',
      date: '2026-02-18',
      status: 'pending',
      amount: 2000,
    ),
    Booking(
      id: 'b3',
      serviceName: 'Painting',
      providerName: 'Colour House',
      citizenName: 'Suman Rai',
      date: '2026-02-20',
      status: 'completed',
      amount: 5000,
    ),
    Booking(
      id: 'b4',
      serviceName: 'Cleaning',
      providerName: 'Clean Nepal',
      citizenName: 'Priya Lama',
      date: '2026-02-22',
      status: 'pending',
      amount: 800,
    ),
  ];

  // ── Government Analytics ────────────────────────
  static const analytics = [
    AnalyticsStat(label: 'Total Providers', value: '8', icon: 'people', changePercent: 12),
    AnalyticsStat(label: 'Active Bookings', value: '4', icon: 'calendar_today', changePercent: 8),
    AnalyticsStat(label: 'Total Courses', value: '5', icon: 'school', changePercent: 20),
    AnalyticsStat(label: 'Citizens Enrolled', value: '146', icon: 'person_add', changePercent: 15),
    AnalyticsStat(label: 'Revenue (Rs.)', value: '9,300', icon: 'account_balance_wallet', changePercent: 5),
    AnalyticsStat(label: 'Pending Approvals', value: '2', icon: 'pending_actions', changePercent: -10),
  ];

  static const allUsers = [
    citizenUser,
    AppUser(
      id: 'c2',
      name: 'Ram Bir',
      phone: '9801111111',
      role: UserRole.citizen,
      location: 'Ward 2, Kathmandu',
      walletBalance: 1200,
      email: 'rambir@example.com',
    ),
    AppUser(
      id: 'c3',
      name: 'Sita Maya',
      phone: '9802222222',
      role: UserRole.citizen,
      location: 'Ward 5, Lalitpur',
      walletBalance: 4500,
      email: 'sitamaya@example.com',
    ),
    governmentUser,
  ];

  static const reports = [
    InfrastructureReport(
      id: 'r1',
      title: 'Broken Water Pipe',
      description: 'Major leak in the main line near the ward office. Water is flooding the street.',
      location: 'Ward 1, Main Road',
      reporterName: 'Abdhesh',
      date: '2026-02-10',
      status: 'pending',
    ),
    InfrastructureReport(
      id: 'r2',
      title: 'Pothole on Bridge',
      description: 'Large pothole on the Bagmati bridge, dangerous for two-wheelers.',
      location: 'Bagmati Bridge, Kupandole',
      reporterName: 'Ram Bir',
      date: '2026-02-11',
      status: 'in_progress',
    ),
    InfrastructureReport(
      id: 'r3',
      title: 'Streetlight Not Working',
      description: 'The streetlights in the inner alley are dark since 3 days.',
      location: 'Lalitpur-5, Alley 4',
      reporterName: 'Sita Maya',
      date: '2026-02-12',
      status: 'resolved',
    ),
  ];

  static const recentAnnouncements = [
    Announcement(
      id: 'a1',
      title: 'Vaccination Drive',
      content: 'Mass vaccination drive for children under 5 starting next week at ward offices.',
      date: '2026-02-10',
      target: 'all',
    ),
    Announcement(
      id: 'a2',
      title: 'New Service Provider Fees',
      content: 'Service charge for providers has been reduced to 5% to encourage local business.',
      date: '2026-02-12',
      target: 'providers',
    ),
  ];
}
