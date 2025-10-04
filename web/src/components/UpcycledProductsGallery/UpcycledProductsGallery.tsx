import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './UpcycledProductsGallery.module.css';

// Import category images from src/assets
import homeDecorImage from '../../assets/home_decor.jpg';
import homeFurnitureImage from '../../assets/home_furniture.jpg';
import craftsImage from '../../assets/crafts.jpg';
import jewelryImage from '../../assets/jewelry.jpg';
import fashionImage from '../../assets/fashion.jpg';

// Import product images from src/assets
import featured1 from '../../assets/featured1.jpg';
import featured2 from '../../assets/featured2.jpg';
import featured3 from '../../assets/featured3.png';
import featured4 from '../../assets/featured4.jpg';
import featured5 from '../../assets/featured5.jpg';
import featured6 from '../../assets/featured6.jpg';
import featured7 from '../../assets/featured7.jpg';
import featured8 from '../../assets/featured8.jpg';   


interface Product {
  id: string;
  title: string;
  artisan: string;
  price: string;
  image: string;
  description: string;
  category: string;
}

const UpcycledProductsGallery: React.FC = () => {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showSignUpModal, setShowSignUpModal] = useState(false);
  const [clickedItem, setClickedItem] = useState<{ type: 'product' | 'category'; name: string } | null>(null);

  // Sample product data - in real app, this would come from an API
  const featuredProducts: Product[] = [
    {
      id: '1',
      title: 'Denim Patchwork Jacket',
      artisan: 'Lexie Grey',
      price: 'M450',
      image: featured1,
      description: 'Unique jacket made from upcycled denim pieces',
      category: 'Fashion'
    },
    {
      id: '2',
      title: 'Skateboard Shelf',
      artisan: 'Philippa Giibwa',
      price: 'M350',
      image: featured2,
      description: 'Creative shelf to hold your books and DVDs, made from a skateboard',
      category: 'Home Furniture'
    },
    {
      id: '3',
      title: 'Plastic bags',
      artisan: 'Cristina Yang',
      price: 'M200',
      image: featured3,
      description: 'Plastic bags weaved into a beautiful and usable bags',
      category: 'Home Decor'
    },
    {
      id: '4',
      title: 'Tin can sculpture',
      artisan: 'Mark Sloan',
      price: 'M150',
      image: featured4,
      description: 'A stunning sculpture made from recycled tin cans',
      category: 'Home Decor'
    }
  ];

  const categories = [
    { name: 'Home Decor', image: homeDecorImage, count: 12 },
    { name: 'Furniture', image: homeFurnitureImage, count: 8 },
    { name: 'Crafts', image: craftsImage, count: 15 },
    { name: 'Jewelry', image: jewelryImage, count: 20 },
    { name: 'Fashion', image: fashionImage, count: 10 }
  ];

  const allProducts: Product[] = [
    ...featuredProducts,
    {
      id: '5',
      title: 'Belt Patchwork Bag',
      artisan: 'Maya Bishop',
      price: 'M300',
      image: featured8,
      description: 'Stylish bag made from upcycled belts',
      category: 'Fashion'
    },
    {
      id: '6',
      title: 'Key Stationary Holder',
      artisan: 'Arizona Robbins',
      price: 'M150',
      image: featured6,
      description: 'A cup to keep your pens and pencils, made from recycled keys',
      category: 'Home Decor'
    },
    {
      id: '7',
      title: 'Shrek Bottle Cap Wall Art',
      artisan: 'Jackson Avery',
      price: 'M520',
      image: featured5,
      description: 'Colourful wall art of Shrek made from recycled bottle caps',
      category: 'Home Decor'
    },
    {
      id: '8',
      title: 'Tyre Couch',
      artisan: 'April Kepner',
      price: 'M1500',
      image: featured7,
      description: 'Comfortable living room chair made from upcycled tires',
      category: 'Furniture'
    }
  ];

  const handleProductClick = (product: Product) => {
    if (!isLoggedIn) {
      setClickedItem({ type: 'product', name: product.title });
      setShowSignUpModal(true);
    } else {
      // Navigate to product detail page
      console.log('View product:', product.title);
    }
  };

  const handleCategoryClick = (category: string) => {
    if (!isLoggedIn) {
      setClickedItem({ type: 'category', name: category });
      setShowSignUpModal(true);
    } else {
      // Filter products by category
      console.log('Filter by category:', category);
    }
  };

  const handleSignUp = () => {
    setIsLoggedIn(true);
    setShowSignUpModal(false);
    // In real app, this would redirect to signup page
  };

  const getModalMessage = () => {
    if (!clickedItem) return '';
    
    if (clickedItem.type === 'product') {
      return `Sign up to get detailed information about "${clickedItem.name}" and connect with the artisan!`;
    } else {
      return `Sign up to explore all products in "${clickedItem.name}" and discover amazing upcycled creations!`;
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
              className={styles.productCard}
              onClick={() => handleProductClick(product)}
            >
              <div className={styles.productImage}>
                <img src={product.image} alt={product.title} />
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
          {categories.map((category) => (
            <div 
              key={category.name}
              className={styles.categoryCard}
              onClick={() => handleCategoryClick(category.name)}
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

      {/* All Products Grid */}
      <section className={styles.section}>
        <div className={styles.sectionHeader}>
          <h2 className={styles.sectionTitle}>All Upcycled Products</h2>
          {!isLoggedIn && (
            <div className={styles.signUpPrompt}>
              <span className="material-symbols-outlined">info</span>
              <span>Sign up to connect with artisans</span>
            </div>
          )}
        </div>

        <div className={styles.productsGrid}>
          {allProducts.map((product) => (
            <div 
              key={product.id}
              className={styles.productCard}
              onClick={() => handleProductClick(product)}
            >
              <div className={styles.productImage}>
                <img src={product.image} alt={product.title} />
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