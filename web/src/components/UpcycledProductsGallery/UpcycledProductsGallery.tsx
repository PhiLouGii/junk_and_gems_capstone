import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './UpcycledProductsGallery.module.css';

// Import category images and product images as fallbacks
import homeDecorImage from '../../assets/home_decor.jpg';
import homeFurnitureImage from '../../assets/home_furniture.jpg';
import craftsImage from '../../assets/crafts.jpg';
import jewelryImage from '../../assets/jewelry.jpg';
import fashionImage from '../../assets/fashion.jpg';
import featured1 from '../../assets/featured1.jpg';
import featured2 from '../../assets/featured2.jpg';
import featured3 from '../../assets/featured3.png';
import featured4 from '../../assets/featured4.jpg';
import featured5 from '../../assets/featured5.jpg';
import featured6 from '../../assets/featured6.jpg';
import featured7 from '../../assets/featured7.jpg';
import featured8 from '../../assets/featured8.jpg';

interface Product {
  _id: string;
  title: string;
  description: string;
  price: number;
  category: string;
  images: string[];
  artisanId?: {
    name?: string;
    _id?: string;
  };
  createdAt?: string;
}

// Fallback products if API fails
const fallbackProducts: Product[] = [
  {
    _id: '1',
    title: 'Denim Patchwork Jacket',
    description: 'Unique jacket made from upcycled denim pieces',
    price: 450,
    category: 'Fashion',
    images: [featured1],
    artisanId: { name: 'Lexie Grey', _id: '1' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '2',
    title: 'Skateboard Shelf',
    description: 'Creative shelf to hold your books and DVDs',
    price: 350,
    category: 'Furniture',
    images: [featured2],
    artisanId: { name: 'Philippa Giibwa', _id: '2' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '3',
    title: 'Plastic Bags Art',
    description: 'Plastic bags weaved into beautiful usable bags',
    price: 200,
    category: 'Home Decor',
    images: [featured3],
    artisanId: { name: 'Cristina Yang', _id: '3' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '4',
    title: 'Tin Can Sculpture',
    description: 'Stunning sculpture made from recycled tin cans',
    price: 150,
    category: 'Home Decor',
    images: [featured4],
    artisanId: { name: 'Mark Sloan', _id: '4' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '5',
    title: 'Belt Patchwork Bag',
    description: 'Stylish bag made from upcycled belts',
    price: 300,
    category: 'Fashion',
    images: [featured8],
    artisanId: { name: 'Maya Bishop', _id: '5' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '6',
    title: 'Key Stationary Holder',
    description: 'Pen holder made from recycled keys',
    price: 150,
    category: 'Home Decor',
    images: [featured6],
    artisanId: { name: 'Arizona Robbins', _id: '6' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '7',
    title: 'Shrek Bottle Cap Wall Art',
    description: 'Colorful wall art made from recycled bottle caps',
    price: 520,
    category: 'Crafts',
    images: [featured5],
    artisanId: { name: 'Jackson Avery', _id: '7' },
    createdAt: new Date().toISOString()
  },
  {
    _id: '8',
    title: 'Tyre Couch',
    description: 'Comfortable chair made from upcycled tires',
    price: 1500,
    category: 'Furniture',
    images: [featured7],
    artisanId: { name: 'April Kepner', _id: '8' },
    createdAt: new Date().toISOString()
  }
];

const UpcycledProductsGallery: React.FC = () => {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showSignUpModal, setShowSignUpModal] = useState(false);
  const [clickedItem, setClickedItem] = useState<{ type: 'product' | 'category'; name: string } | null>(null);
  
  // Dynamic state
  const [products, setProducts] = useState<Product[]>(fallbackProducts);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

  // Fetch products from API
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        console.log('Fetching products from API...');
        setLoading(true);
        
        const response = await fetch(`${API_BASE_URL}/api/products`);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('API Response:', data);
        
        if (Array.isArray(data) && data.length > 0) {
          setProducts(data);
          console.log('Products loaded from API:', data.length);
        } else {
          console.log('API returned empty array, using fallback products');
          setProducts(fallbackProducts);
        }
      } catch (err) {
        console.error('Error fetching products:', err);
        console.log('Using fallback products due to error');
        setProducts(fallbackProducts);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  // Calculate categories dynamically from products
  const categories = React.useMemo(() => {
    const categoryMap = new Map<string, number>();
    
    products.forEach(product => {
      const cat = product.category || 'Other';
      categoryMap.set(cat, (categoryMap.get(cat) || 0) + 1);
    });

    const categoryImages: Record<string, string> = {
      'Home Decor': homeDecorImage,
      'Furniture': homeFurnitureImage,
      'Crafts': craftsImage,
      'Jewelry': jewelryImage,
      'Fashion': fashionImage,
    };

    return Array.from(categoryMap.entries()).map(([name, count]) => ({
      name,
      count,
      image: categoryImages[name] || homeDecorImage
    }));
  }, [products]);

  // Filter products based on search and category
  const filteredProducts = React.useMemo(() => {
    let filtered = products;

    if (selectedCategory) {
      filtered = filtered.filter(p => p.category === selectedCategory);
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(p => 
        p.title.toLowerCase().includes(query) ||
        p.description.toLowerCase().includes(query) ||
        (p.artisanId?.name && p.artisanId.name.toLowerCase().includes(query))
      );
    }

    return filtered;
  }, [products, searchQuery, selectedCategory]);

  // Featured products (latest 4)
  const featuredProducts = React.useMemo(() => {
    return [...products]
      .sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime())
      .slice(0, 4);
  }, [products]);

  const handleProductClick = (product: Product) => {
    if (!isLoggedIn) {
      setClickedItem({ type: 'product', name: product.title });
      setShowSignUpModal(true);
    } else {
      console.log('View product:', product.title);
    }
  };

  const handleCategoryClick = (category: string) => {
    if (!isLoggedIn) {
      setClickedItem({ type: 'category', name: category });
      setShowSignUpModal(true);
    } else {
      setSelectedCategory(selectedCategory === category ? null : category);
      window.scrollTo({ top: 600, behavior: 'smooth' });
    }
  };

  const handleSignUp = () => {
    setIsLoggedIn(true);
    setShowSignUpModal(false);
  };

  const getModalMessage = () => {
    if (!clickedItem) return '';
    
    if (clickedItem.type === 'product') {
      return `Sign up to get detailed information about "${clickedItem.name}" and connect with the artisan!`;
    } else {
      return `Sign up to explore all products in "${clickedItem.name}" and discover amazing upcycled creations!`;
    }
  };

  const formatPrice = (price: number) => {
    return `M${price.toFixed(2)}`;
  };

  return (
    <div className={styles.container}>
      {/* Header - Always visible */}
      <header className={styles.header}>
        <button 
          className={styles.backButton}
          onClick={() => navigate('/')}
        >
          <span className="material-symbols-outlined">arrow_back</span>
        </button>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Upcycled Products Gallery</h1>
        </div>
        <div className={styles.headerSpacer}></div>
      </header>

      {/* Search Bar - Always visible */}
      <div className={styles.searchBar}>
        <span className="material-symbols-outlined">search</span>
        <input
          type="text"
          placeholder="Search upcycled products, artisans..."
          className={styles.searchInput}
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      {/* Stats Bar - Always visible */}
      <div className={styles.statsBar}>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>{loading ? '...' : `${products.length}+`}</span>
          <span className={styles.statLabel}>Upcycled Products</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>
            {loading ? '...' : `${new Set(products.map(p => p.artisanId?._id).filter(Boolean)).size}+`}
          </span>
          <span className={styles.statLabel}>Talented Artisans</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>{loading ? '...' : `${categories.length}+`}</span>
          <span className={styles.statLabel}>Categories</span>
        </div>
      </div>

      {/* Loading State */}
      {loading && (
        <div style={{ textAlign: 'center', padding: '60px 20px' }}>
          <div style={{ fontSize: '48px', marginBottom: '16px' }}>⏳</div>
          <p style={{ color: '#666', fontSize: '18px' }}>Loading amazing upcycled creations...</p>
        </div>
      )}

      {/* Featured Products */}
      {!loading && featuredProducts.length > 0 && (
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Featured Upcycled Creations</h2>
          <p className={styles.sectionSubtitle}>Discover our latest unique items crafted from recycled materials</p>
          
          <div className={styles.featuredGrid}>
            {featuredProducts.map((product) => (
              <div 
                key={product._id} 
                className={styles.productCard}
                onClick={() => handleProductClick(product)}
              >
                <div className={styles.productImage}>
                  {product.images && product.images.length > 0 ? (
                    <img src={product.images[0]} alt={product.title} onError={(e) => {
                      e.currentTarget.src = homeDecorImage;
                    }} />
                  ) : (
                    <img src={homeDecorImage} alt={product.title} />
                  )}
                </div>
                <div className={styles.productInfo}>
                  <h3 className={styles.productTitle}>{product.title}</h3>
                  <p className={styles.productArtisan}>
                    By {product.artisanId?.name || 'Local Artisan'}
                  </p>
                  <div className={styles.productPrice}>{formatPrice(product.price)}</div>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Categories */}
      {!loading && categories.length > 0 && (
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Browse Categories</h2>
          <div className={styles.categoriesGrid}>
            {categories.map((category) => (
              <div 
                key={category.name}
                className={styles.categoryCard}
                onClick={() => handleCategoryClick(category.name)}
                style={{
                  border: selectedCategory === category.name ? '2px solid #88844D' : 'none',
                  transform: selectedCategory === category.name ? 'scale(1.05)' : 'scale(1)',
                  transition: 'all 0.3s'
                }}
              >
                <div className={styles.categoryImage}>
                  <img src={category.image} alt={category.name} />
                </div>
                <div className={styles.categoryInfo}>
                  <h3 className={styles.categoryName}>{category.name}</h3>
                  <p className={styles.categoryCount}>{category.count} products</p>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* All Products Grid */}
      {!loading && (
        <section className={styles.section}>
          <div className={styles.sectionHeader}>
            <h2 className={styles.sectionTitle}>
              {selectedCategory 
                ? `${selectedCategory} Products` 
                : searchQuery 
                  ? `Search Results` 
                  : 'All Upcycled Products'}
            </h2>
            {!isLoggedIn && (
              <div className={styles.signUpPrompt}>
                <span className="material-symbols-outlined">info</span>
                <span>Sign up to connect with artisans</span>
              </div>
            )}
          </div>

          {selectedCategory && (
            <button 
              onClick={() => setSelectedCategory(null)}
              style={{
                background: '#88844D',
                color: 'white',
                border: 'none',
                padding: '8px 16px',
                borderRadius: '8px',
                cursor: 'pointer',
                marginBottom: '16px',
                fontSize: '14px'
              }}
            >
              ← Show All Categories
            </button>
          )}

          {filteredProducts.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px' }}>
              <div style={{ fontSize: '64px', marginBottom: '16px' }}>🔍</div>
              <p style={{ color: '#666', fontSize: '18px' }}>
                {searchQuery 
                  ? `No products found for "${searchQuery}"` 
                  : 'No products available yet'}
              </p>
            </div>
          ) : (
            <div className={styles.productsGrid}>
              {filteredProducts.map((product) => (
                <div 
                  key={product._id}
                  className={styles.productCard}
                  onClick={() => handleProductClick(product)}
                >
                  <div className={styles.productImage}>
                    {product.images && product.images.length > 0 ? (
                      <img src={product.images[0]} alt={product.title} onError={(e) => {
                        e.currentTarget.src = homeDecorImage;
                      }} />
                    ) : (
                      <img src={homeDecorImage} alt={product.title} />
                    )}
                  </div>
                  <div className={styles.productInfo}>
                    <h3 className={styles.productTitle}>{product.title}</h3>
                    <p className={styles.productArtisan}>
                      By {product.artisanId?.name || 'Local Artisan'}
                    </p>
                    <div className={styles.productMeta}>
                      <span className={styles.productCategory}>{product.category}</span>
                      <span className={styles.productPrice}>{formatPrice(product.price)}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      )}

      {/* Sign Up CTA Section */}
      {!isLoggedIn && !loading && (
        <section className={styles.ctaSection}>
          <div className={styles.ctaContent}>
            <div className={styles.ctaIcon}>
              <span className="material-symbols-outlined">eco</span>
            </div>
            <h2 className={styles.ctaTitle}>Join Our Creative Community</h2>
            <p className={styles.ctaDescription}>
              Unlock access to hundreds of unique upcycled products, connect with talented artisans, 
              and be part of the sustainable movement.
            </p>
            <div className={styles.ctaButtons}>
              <button 
                className={styles.primaryButton}
                onClick={handleSignUp}
              >
                Sign Up to Explore
              </button>
              <button className={styles.secondaryButton}>
                Learn More
              </button>
            </div>
          </div>
        </section>
      )}

      {/* Sign Up Modal */}
      {showSignUpModal && (
        <div className={styles.modalOverlay}>
          <div className={styles.modal}>
            <div className={styles.modalHeader}>
              <span className="material-symbols-outlined">auto_awesome</span>
              <h3>Join Our Community</h3>
              <button 
                className={styles.closeButton}
                onClick={() => setShowSignUpModal(false)}
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            <div className={styles.modalContent}>
              <p>{getModalMessage()}</p>
              <ul className={styles.benefitsList}>
                <li>Connect directly with artisans</li>
                <li>Get detailed product information</li>
                <li>Save your favorite products</li>
                <li>Purchase unique upcycled items</li>
              </ul>
            </div>
            <div className={styles.modalActions}>
              <button 
                className={styles.primaryButton}
                onClick={handleSignUp}
              >
                Sign Up Now
              </button>
              <button 
                className={styles.secondaryButton}
                onClick={() => setShowSignUpModal(false)}
              >
                Continue Browsing
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UpcycledProductsGallery;