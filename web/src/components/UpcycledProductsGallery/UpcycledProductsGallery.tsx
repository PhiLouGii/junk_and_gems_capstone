import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './UpcycledProductsGallery.module.css';

// Import category images from src/assets (keep these as fallbacks)
import homeDecorImage from '../../assets/home_decor.jpg';
import homeFurnitureImage from '../../assets/home_furniture.jpg';
import craftsImage from '../../assets/crafts.jpg';
import jewelryImage from '../../assets/jewelry.jpg';
import fashionImage from '../../assets/fashion.jpg';

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

const UpcycledProductsGallery: React.FC = () => {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showSignUpModal, setShowSignUpModal] = useState(false);
  const [clickedItem, setClickedItem] = useState<{ type: 'product' | 'category'; name: string } | null>(null);
  
  // Dynamic state
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

  // Fetch products from API
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        setLoading(true);
        const response = await fetch(`${API_BASE_URL}/api/products`);
        
        if (!response.ok) {
          throw new Error('Failed to fetch products');
        }

        const data = await response.json();
        setProducts(data);
        setError(null);
      } catch (err) {
        console.error('Error fetching products:', err);
        setError('Unable to load products. Please try again later.');
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
      // Navigate to product detail page
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
      {/* Header */}
      <header className={styles.header}>
        <button 
          className={styles.backButton}
          onClick={() => navigate(-1)}
        >
          <span className="material-symbols-outlined">arrow_back</span>
        </button>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Upcycled Products Gallery</h1>
        </div>
        <div className={styles.headerSpacer}></div>
      </header>

      {/* Search Bar */}
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

      {/* Stats Bar */}
      <div className={styles.statsBar}>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>{products.length}+</span>
          <span className={styles.statLabel}>Upcycled Products</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>{new Set(products.map(p => p.artisanId?._id).filter(Boolean)).size}+</span>
          <span className={styles.statLabel}>Talented Artisans</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>{categories.length}+</span>
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

      {/* Error State */}
      {error && (
        <div style={{ 
          textAlign: 'center', 
          padding: '40px 20px', 
          margin: '20px',
          background: '#fff3cd',
          borderRadius: '12px',
          border: '1px solid #ffeaa7'
        }}>
          <div style={{ fontSize: '48px', marginBottom: '16px' }}>⚠️</div>
          <p style={{ color: '#856404', fontSize: '16px' }}>{error}</p>
        </div>
      )}

      {/* Featured Products */}
      {!loading && !error && featuredProducts.length > 0 && (
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
      {!loading && !error && categories.length > 0 && (
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
                  transform: selectedCategory === category.name ? 'scale(1.05)' : 'scale(1)'
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
      {!loading && !error && (
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