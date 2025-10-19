export interface User {
  id: number;
  name: string;
  email: string;
  username: string;
  user_type: 'contributor' | 'artisan' | 'both';
  available_gems: number;
  donation_count: number;
  created_at: string;
  profile_image_url?: string;
  specialty?: string;
  bio?: string;
}

export interface Material {
  id: number;
  title: string;
  description: string;
  category: string;
  quantity: string;
  location: string;
  uploader_id: number;
  uploader_name: string;
  is_claimed: boolean;
  created_at: string;
  image_urls: string[];
}

export interface Product {
  id: number;
  title: string;
  description: string;
  price: number;
  category: string;
  artisan_id: number;
  creator_name: string;
  created_at: string;
  image_data_base64?: string[];
}

export interface DashboardStats {
  totalUsers: number;
  totalMaterials: number;
  totalProducts: number;
  totalGems: number;
  activeConversations: number;
  todayRegistrations: number;
  pendingMaterials: number;
  suspendedAccounts: number;
}