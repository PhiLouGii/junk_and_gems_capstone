import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './UpcycledProductsGallery.module.css';

import homeDecorImage from '../../assets/home_decor.jpg';
import homeFurnitureImage from '../../assets/home_furniture.jpg';
import craftsImage from '../../assets/crafts.jpg';
import jewelryImage from '../../assets/jewelry.jpg';
import fashionImage from '../../assets/fashion.jpg';

interface Product {
  id: string;
  title: string;
  artisan: string;
  price: string;
  image: string;
  description: string;
  category: string;
  isBlurred?: boolean;
}

const UpcycledProductsGallery: React.FC = () => {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showSignUpModal, setShowSignUpModal] = useState(false);

  // Sample product data - in real app, this would come from an API
  const featuredProducts: Product[] = [
    {
      id: '1',
      title: 'Denim Patchwork Jacket',
      artisan: 'Lexie Grey',
      price: 'M450',
      image: '/assets/images/featured1.jpg',
      description: 'Unique jacket made from upcycled denim pieces',
      category: 'Fashion',
      isBlurred: true
    },
    {
      id: '2',
      title: 'Plastic Bottle Lamp',
      artisan: 'Philippa Giibwa',
      price: 'M380',
      image: '/assets/images/featured2.jpg',
      description: 'Creative lamp made from recycled plastic bottles',
      category: 'Home Decor',
      isBlurred: true
    },
    {
      id: '3',
      title: 'Sta-Soft Lamp',
      artisan: 'Cristina Yang',
      price: 'M400',
      image: '/assets/images/featured3.jpg',
      description: 'Innovative lamp crafted from upcycled fabric softener containers',
      category: 'Home Decor',
      isBlurred: true
    },
    {
      id: '4',
      title: 'CD Chandelier',
      artisan: 'Mark Sloan',
      price: 'M550',
      image: '/assets/images/featured4.jpg',
      description: 'Beautiful chandelier made from recycled CDs',
      category: 'Home Decor',
      isBlurred: true
    }
  ];

  const categories = [
    { name: 'Home Decor', image: homeDecorImage, count: 12 },
    { name: 'Furniture', image: homeFurnitureImage, count: 8 },
    { name: 'Crafts', image: craftsImage, count: 15 },
    { name: 'Jewelry', image: jewelryImage, count: 20 },
    { name: 'Fashion', image: fashionImage,  count: 10 }
  ];

  const allProducts: Product[] = [
    ...featuredProducts,
    {
      id: '5',
      title: 'Denim Patchwork Bag',
      artisan: 'Maya Bishop',
      price: 'M330',
      image: '/assets/images/upcycled1.jpg',
      description: 'Stylish bag made from upcycled denim',
      category: 'Fashion',
      isBlurred: true
    },
    {
      id: '6',
      title: 'RedBull Lamp',
      artisan: 'Arizona Robbins',
      price: 'M450',
      image: '/assets/images/featured6.jpg',
      description: 'Creative lamp made from RedBull cans',
      category: 'Home Decor',
      isBlurred: true
    }
  ];

  const handleProductClick = (product: Product) => {
    if (!isLoggedIn) {
      setShowSignUpModal(true);
    } else {
      // Navigate to product detail page
      console.log('View product:', product.title);
    }
  };

  const handleSignUp = () => {
    setIsLoggedIn(true);
    setShowSignUpModal(false);
    // In real app, this would redirect to signup page
  };

  const handleCategoryClick = (category: string) => {
    if (!isLoggedIn) {
      setShowSignUpModal(true);
    } else {
      // Filter products by category
      console.log('Filter by category:', category);
    }
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
        />
      </div>

      {/* Stats Bar */}
      <div className={styles.statsBar}>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>150+</span>
          <span className={styles.statLabel}>Upcycled Products</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>50+</span>
          <span className={styles.statLabel}>Talented Artisans</span>
        </div>
        <div className={styles.statItem}>
          <span className={styles.statNumber}>5+</span>
          <span className={styles.statLabel}>Categories</span>
        </div>
      </div>

      {/* Featured Products */}
      <section className={styles.section}>
        <h2 className={styles.sectionTitle}>Featured Upcycled Creations</h2>
        <p className={styles.sectionSubtitle}>Discover unique items crafted from recycled materials</p>
        
        <div className={styles.featuredGrid}>
          {featuredProducts.map((product) => (
            <div 
              key={product.id} 
              className={`${styles.productCard} ${!isLoggedIn ? styles.blurred : ''}`}
              onClick={() => handleProductClick(product)}
            >
              <div className={styles.productImage}>
                <img src={product.image} alt={product.title} />
                {!isLoggedIn && (
                  <div className={styles.blurOverlay}>
                    <span className="material-symbols-outlined">lock</span>
                    <p>Sign up to view</p>
                  </div>
                )}
              </div>
              <div className={styles.productInfo}>
                <h3 className={styles.productTitle}>{product.title}</h3>
                <p className={styles.productArtisan}>By {product.artisan}</p>
                <div className={styles.productPrice}>{product.price}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Categories */}
      <section className={styles.section}>
        <h2 className={styles.sectionTitle}>Browse Categories</h2>
        <div className={styles.categoriesGrid}>
          {categories.map((category, index) => (
            <div 
              key={category.name}
              className={`${styles.categoryCard} ${!isLoggedIn && index > 1 ? styles.blurred : ''}`}
              onClick={() => handleCategoryClick(category.name)}
            >
              <div className={styles.categoryImage}>
                <img src={category.image} alt={category.name} />
                {!isLoggedIn && index > 1 && (
                  <div className={styles.blurOverlay}>
                    <span className="material-symbols-outlined">lock</span>
                  </div>
                )}
              </div>
              <div className={styles.categoryInfo}>
                <h3 className={styles.categoryName}>{category.name}</h3>
                <p className={styles.categoryCount}>{category.count} products</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* All Products Grid */}
      <section className={styles.section}>
        <div className={styles.sectionHeader}>
          <h2 className={styles.sectionTitle}>All Upcycled Products</h2>
          {!isLoggedIn && (
            <div className={styles.signUpPrompt}>
              <span className="material-symbols-outlined">info</span>
              <span>Sign up to unlock all products</span>
            </div>
          )}
        </div>

        <div className={styles.productsGrid}>
          {allProducts.map((product, index) => (
            <div 
              key={product.id}
              className={`${styles.productCard} ${!isLoggedIn ? styles.blurred : ''}`}
              onClick={() => handleProductClick(product)}
            >
              <div className={styles.productImage}>
                <img src={product.image} alt={product.title} />
                {!isLoggedIn && (
                  <div className={styles.blurOverlay}>
                    <span className="material-symbols-outlined">lock</span>
                    <p>Sign up to view details</p>
                  </div>
                )}
              </div>
              <div className={styles.productInfo}>
                <h3 className={styles.productTitle}>{product.title}</h3>
                <p className={styles.productArtisan}>By {product.artisan}</p>
                <div className={styles.productMeta}>
                  <span className={styles.productCategory}>{product.category}</span>
                  <span className={styles.productPrice}>{product.price}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Sign Up CTA Section */}
      {!isLoggedIn && (
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
              <span className="material-symbols-outlined">lock</span>
              <h3>Oops... Content Locked</h3>
              <button 
                className={styles.closeButton}
                onClick={() => setShowSignUpModal(false)}
              >
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            <div className={styles.modalContent}>
              <p>Sign up to unlock all upcycled products and connect with our creative community!</p>
              <ul className={styles.benefitsList}>
                <li>Browse hundreds of unique upcycled items</li>
                <li>Connect directly with artisans</li>
                <li>Get early access to new creations</li>
                <li>Join the sustainable movement</li>
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
                Maybe Later
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UpcycledProductsGallery;