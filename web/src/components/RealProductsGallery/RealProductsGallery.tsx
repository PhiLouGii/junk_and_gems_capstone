import React, { useState, useEffect } from 'react';

interface Product {
  id: string;
  title: string;
  description: string;
  price: number;
  category: string;
  image_data_base64: string[];
  creator_name: string;
  creator_avatar?: string;
  created_at: string;
  condition?: string;
  materials_used?: string;
}

const RealProductsGallery = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [showProductModal, setShowProductModal] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      setError('');
      
      console.log('🔄 Fetching products from API...');
      const response = await fetch(`${API_BASE_URL}/api/products`);
      
      if (!response.ok) {
        throw new Error(`Failed to fetch products: ${response.status}`);
      }

      const data = await response.json();
      console.log('✅ Products loaded:', data.length);
      
      setProducts(data);
    } catch (err) {
      console.error('❌ Error fetching products:', err);
      setError('Unable to load products. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  // Calculate categories from real products
  const categories = React.useMemo(() => {
    const categoryMap = new Map<string, number>();
    
    products.forEach(product => {
      const cat = product.category || 'Other';
      categoryMap.set(cat, (categoryMap.get(cat) || 0) + 1);
    });

    return Array.from(categoryMap.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count);
  }, [products]);

  // Filter products
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
        p.creator_name?.toLowerCase().includes(query) ||
        p.category?.toLowerCase().includes(query)
      );
    }

    return filtered;
  }, [products, searchQuery, selectedCategory]);

  // Featured products (newest 4)
  const featuredProducts = React.useMemo(() => {
    return [...products]
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 4);
  }, [products]);

  const formatPrice = (price: number) => {
    return `M${price.toFixed(2)}`;
  };

  const getProductImage = (product: Product) => {
    if (product.image_data_base64 && product.image_data_base64.length > 0) {
      return product.image_data_base64[0];
    }
    return 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400';
  };

  const handleProductClick = (product: Product) => {
    setSelectedProduct(product);
    setShowProductModal(true);
  };

  const handleCategoryClick = (category: string) => {
    setSelectedCategory(selectedCategory === category ? null : category);
    window.scrollTo({ top: 400, behavior: 'smooth' });
  };

  if (loading) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%)',
        flexDirection: 'column',
        gap: '1rem'
      }}>
        <div style={{
          border: '4px solid #f3f3f3',
          borderTop: '4px solid #88844D',
          borderRadius: '50%',
          width: '60px',
          height: '60px',
          animation: 'spin 1s linear infinite'
        }} />
        <p style={{ color: '#666', fontSize: '1.125rem', fontWeight: '500' }}>
          Loading products from database...
        </p>
        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%)',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    }}>
      {/* Header */}
      <header style={{
        background: 'white',
        boxShadow: '0 2px 12px rgba(0,0,0,0.08)',
        position: 'sticky',
        top: 0,
        zIndex: 100
      }}>
        <div style={{
          maxWidth: '1400px',
          margin: '0 auto',
          padding: '1.5rem 2rem',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <h1 style={{
            margin: 0,
            fontSize: '1.75rem',
            fontWeight: '700',
            color: '#88844D'
          }}>
            🌍 Upcycled Products Gallery
          </h1>
          <button
            onClick={fetchProducts}
            style={{
              padding: '0.625rem 1.25rem',
              background: '#88844D',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontWeight: '600',
              fontSize: '0.875rem'
            }}
          >
            🔄 Refresh
          </button>
        </div>
      </header>

      <div style={{ maxWidth: '1400px', margin: '0 auto', padding: '2rem' }}>
        
        {/* Error Message */}
        {error && (
          <div style={{
            background: '#fee2e2',
            border: '1px solid #ef4444',
            borderRadius: '12px',
            padding: '1rem 1.5rem',
            marginBottom: '2rem',
            color: '#991b1b'
          }}>
            ⚠️ {error}
          </div>
        )}

        {/* Search Bar */}
        <div style={{
          background: 'white',
          borderRadius: '12px',
          padding: '1rem 1.5rem',
          marginBottom: '2rem',
          boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
          display: 'flex',
          alignItems: 'center',
          gap: '1rem'
        }}>
          <span style={{ fontSize: '1.25rem' }}>🔍</span>
          <input
            type="text"
            placeholder="Search products, artisans, categories..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{
              flex: 1,
              border: 'none',
              outline: 'none',
              fontSize: '1rem',
              background: 'transparent'
            }}
          />
        </div>

        {/* Stats Bar */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
          gap: '1.5rem',
          marginBottom: '3rem'
        }}>
          <div style={{
            background: 'linear-gradient(135deg, #88844D 0%, #BEC092 100%)',
            borderRadius: '16px',
            padding: '2rem',
            color: 'white',
            textAlign: 'center',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
          }}>
            <div style={{ fontSize: '2.5rem', fontWeight: '700', marginBottom: '0.5rem' }}>
              {products.length}
            </div>
            <div style={{ fontSize: '0.875rem', opacity: 0.9 }}>
              Upcycled Products
            </div>
          </div>
          
          <div style={{
            background: 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)',
            borderRadius: '16px',
            padding: '2rem',
            color: 'white',
            textAlign: 'center',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
          }}>
            <div style={{ fontSize: '2.5rem', fontWeight: '700', marginBottom: '0.5rem' }}>
              {new Set(products.map(p => p.creator_name)).size}
            </div>
            <div style={{ fontSize: '0.875rem', opacity: 0.9 }}>
              Talented Artisans
            </div>
          </div>
          
          <div style={{
            background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
            borderRadius: '16px',
            padding: '2rem',
            color: 'white',
            textAlign: 'center',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
          }}>
            <div style={{ fontSize: '2.5rem', fontWeight: '700', marginBottom: '0.5rem' }}>
              {categories.length}
            </div>
            <div style={{ fontSize: '0.875rem', opacity: 0.9 }}>
              Categories
            </div>
          </div>
        </div>

        {/* Categories */}
        {categories.length > 0 && (
          <div style={{ marginBottom: '3rem' }}>
            <h2 style={{
              fontSize: '1.5rem',
              fontWeight: '700',
              color: '#88844D',
              marginBottom: '1.5rem'
            }}>
              📂 Browse by Category
            </h2>
            <div style={{
              display: 'flex',
              gap: '1rem',
              flexWrap: 'wrap'
            }}>
              {categories.map(category => (
                <button
                  key={category.name}
                  onClick={() => handleCategoryClick(category.name)}
                  style={{
                    padding: '0.75rem 1.5rem',
                    background: selectedCategory === category.name ? '#88844D' : 'white',
                    color: selectedCategory === category.name ? 'white' : '#88844D',
                    border: `2px solid ${selectedCategory === category.name ? '#88844D' : '#BEC092'}`,
                    borderRadius: '24px',
                    cursor: 'pointer',
                    fontWeight: '600',
                    fontSize: '0.875rem',
                    transition: 'all 0.2s',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem'
                  }}
                  onMouseOver={(e) => {
                    if (selectedCategory !== category.name) {
                      e.currentTarget.style.background = '#f3f4f6';
                    }
                  }}
                  onMouseOut={(e) => {
                    if (selectedCategory !== category.name) {
                      e.currentTarget.style.background = 'white';
                    }
                  }}
                >
                  {category.name}
                  <span style={{
                    background: selectedCategory === category.name ? 'rgba(255,255,255,0.3)' : '#BEC092',
                    color: selectedCategory === category.name ? 'white' : '#88844D',
                    padding: '0.125rem 0.5rem',
                    borderRadius: '12px',
                    fontSize: '0.75rem',
                    fontWeight: '700'
                  }}>
                    {category.count}
                  </span>
                </button>
              ))}
              {selectedCategory && (
                <button
                  onClick={() => setSelectedCategory(null)}
                  style={{
                    padding: '0.75rem 1.5rem',
                    background: '#ef4444',
                    color: 'white',
                    border: 'none',
                    borderRadius: '24px',
                    cursor: 'pointer',
                    fontWeight: '600',
                    fontSize: '0.875rem'
                  }}
                >
                  ✕ Clear Filter
                </button>
              )}
            </div>
          </div>
        )}

        {/* Featured Products */}
        {featuredProducts.length > 0 && !selectedCategory && !searchQuery && (
          <div style={{ marginBottom: '3rem' }}>
            <h2 style={{
              fontSize: '1.5rem',
              fontWeight: '700',
              color: '#88844D',
              marginBottom: '1rem'
            }}>
              ⭐ Featured Products
            </h2>
            <p style={{ color: '#666', marginBottom: '1.5rem' }}>
              Discover our latest unique items crafted from recycled materials
            </p>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
              gap: '1.5rem'
            }}>
              {featuredProducts.map(product => (
                <div
                  key={product.id}
                  onClick={() => handleProductClick(product)}
                  style={{
                    background: 'white',
                    borderRadius: '16px',
                    overflow: 'hidden',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                    cursor: 'pointer',
                    transition: 'all 0.3s'
                  }}
                  onMouseOver={(e) => {
                    e.currentTarget.style.transform = 'translateY(-8px)';
                    e.currentTarget.style.boxShadow = '0 12px 24px rgba(0,0,0,0.15)';
                  }}
                  onMouseOut={(e) => {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.08)';
                  }}
                >
                  <div style={{
                    height: '200px',
                    overflow: 'hidden',
                    background: '#f3f4f6'
                  }}>
                    <img
                      src={getProductImage(product)}
                      alt={product.title}
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover'
                      }}
                      onError={(e) => {
                        e.currentTarget.src = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400';
                      }}
                    />
                  </div>
                  <div style={{ padding: '1.25rem' }}>
                    <h3 style={{
                      margin: '0 0 0.5rem 0',
                      fontSize: '1.125rem',
                      fontWeight: '700',
                      color: '#1f2937',
                      lineHeight: '1.4'
                    }}>
                      {product.title}
                    </h3>
                    <p style={{
                      margin: '0 0 0.75rem 0',
                      fontSize: '0.875rem',
                      color: '#6b7280',
                      display: '-webkit-box',
                      WebkitLineClamp: 2,
                      WebkitBoxOrient: 'vertical',
                      overflow: 'hidden'
                    }}>
                      {product.description}
                    </p>
                    <div style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      marginTop: '1rem'
                    }}>
                      <span style={{
                        fontSize: '0.75rem',
                        color: '#88844D',
                        fontWeight: '600'
                      }}>
                        By {product.creator_name}
                      </span>
                      <span style={{
                        fontSize: '1.25rem',
                        fontWeight: '700',
                        color: '#88844D'
                      }}>
                        {formatPrice(product.price)}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* All Products */}
        <div>
          <h2 style={{
            fontSize: '1.5rem',
            fontWeight: '700',
            color: '#88844D',
            marginBottom: '1.5rem'
          }}>
            {selectedCategory 
              ? `${selectedCategory} Products (${filteredProducts.length})` 
              : searchQuery 
                ? `Search Results (${filteredProducts.length})`
                : `All Products (${products.length})`}
          </h2>

          {filteredProducts.length === 0 ? (
            <div style={{
              textAlign: 'center',
              padding: '4rem 2rem',
              background: 'white',
              borderRadius: '16px',
              boxShadow: '0 2px 12px rgba(0,0,0,0.08)'
            }}>
              <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🔍</div>
              <h3 style={{ fontSize: '1.5rem', color: '#374151', marginBottom: '0.5rem' }}>
                No Products Found
              </h3>
              <p style={{ color: '#6b7280' }}>
                {searchQuery 
                  ? `No products match "${searchQuery}". Try a different search term.`
                  : selectedCategory
                    ? `No products in "${selectedCategory}" category yet.`
                    : 'No products available in the database yet.'}
              </p>
            </div>
          ) : (
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
              gap: '1.5rem'
            }}>
              {filteredProducts.map(product => (
                <div
                  key={product.id}
                  onClick={() => handleProductClick(product)}
                  style={{
                    background: 'white',
                    borderRadius: '12px',
                    overflow: 'hidden',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
                    cursor: 'pointer',
                    transition: 'all 0.2s'
                  }}
                  onMouseOver={(e) => {
                    e.currentTarget.style.transform = 'translateY(-4px)';
                    e.currentTarget.style.boxShadow = '0 8px 16px rgba(0,0,0,0.12)';
                  }}
                  onMouseOut={(e) => {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,0,0,0.08)';
                  }}
                >
                  <div style={{
                    height: '180px',
                    overflow: 'hidden',
                    background: '#f3f4f6'
                  }}>
                    <img
                      src={getProductImage(product)}
                      alt={product.title}
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover'
                      }}
                      onError={(e) => {
                        e.currentTarget.src = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400';
                      }}
                    />
                  </div>
                  <div style={{ padding: '1rem' }}>
                    <div style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'flex-start',
                      marginBottom: '0.5rem'
                    }}>
                      <h3 style={{
                        margin: 0,
                        fontSize: '1rem',
                        fontWeight: '600',
                        color: '#1f2937',
                        flex: 1
                      }}>
                        {product.title}
                      </h3>
                      <span style={{
                        padding: '0.25rem 0.5rem',
                        background: '#BEC092',
                        color: '#88844D',
                        borderRadius: '6px',
                        fontSize: '0.7rem',
                        fontWeight: '600',
                        marginLeft: '0.5rem'
                      }}>
                        {product.category}
                      </span>
                    </div>
                    <p style={{
                      margin: '0 0 0.75rem 0',
                      fontSize: '0.75rem',
                      color: '#6b7280'
                    }}>
                      By {product.creator_name}
                    </p>
                    <div style={{
                      fontSize: '1.125rem',
                      fontWeight: '700',
                      color: '#88844D'
                    }}>
                      {formatPrice(product.price)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Product Detail Modal */}
      {showProductModal && selectedProduct && (
        <div
          onClick={() => setShowProductModal(false)}
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(0,0,0,0.7)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            padding: '2rem'
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              background: 'white',
              borderRadius: '24px',
              maxWidth: '800px',
              width: '100%',
              maxHeight: '90vh',
              overflow: 'auto',
              boxShadow: '0 24px 48px rgba(0,0,0,0.3)'
            }}
          >
            <div style={{ position: 'relative' }}>
              <img
                src={getProductImage(selectedProduct)}
                alt={selectedProduct.title}
                style={{
                  width: '100%',
                  height: '400px',
                  objectFit: 'cover'
                }}
                onError={(e) => {
                  e.currentTarget.src = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800';
                }}
              />
              <button
                onClick={() => setShowProductModal(false)}
                style={{
                  position: 'absolute',
                  top: '1rem',
                  right: '1rem',
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  background: 'white',
                  border: 'none',
                  cursor: 'pointer',
                  fontSize: '1.5rem',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
                }}
              >
                ✕
              </button>
            </div>
            <div style={{ padding: '2rem' }}>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'flex-start',
                marginBottom: '1rem'
              }}>
                <div>
                  <h2 style={{
                    margin: '0 0 0.5rem 0',
                    fontSize: '2rem',
                    fontWeight: '700',
                    color: '#1f2937'
                  }}>
                    {selectedProduct.title}
                  </h2>
                  <p style={{
                    margin: 0,
                    fontSize: '1rem',
                    color: '#6b7280'
                  }}>
                    By {selectedProduct.creator_name}
                  </p>
                </div>
                <div style={{
                  fontSize: '2rem',
                  fontWeight: '700',
                  color: '#88844D'
                }}>
                  {formatPrice(selectedProduct.price)}
                </div>
              </div>

              <div style={{
                padding: '1rem',
                background: '#F7F2E4',
                borderRadius: '12px',
                marginBottom: '1.5rem'
              }}>
                <p style={{
                  margin: 0,
                  fontSize: '1rem',
                  color: '#374151',
                  lineHeight: '1.6'
                }}>
                  {selectedProduct.description}
                </p>
              </div>

              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                gap: '1rem',
                marginBottom: '1.5rem'
              }}>
                <div>
                  <div style={{
                    fontSize: '0.75rem',
                    color: '#6b7280',
                    marginBottom: '0.25rem',
                    fontWeight: '600'
                  }}>
                    Category
                  </div>
                  <div style={{
                    fontSize: '1rem',
                    color: '#1f2937',
                    fontWeight: '600'
                  }}>
                    {selectedProduct.category}
                  </div>
                </div>
                {selectedProduct.condition && (
                  <div>
                    <div style={{
                      fontSize: '0.75rem',
                      color: '#6b7280',
                      marginBottom: '0.25rem',
                      fontWeight: '600'
                    }}>
                      Condition
                    </div>
                    <div style={{
                      fontSize: '1rem',
                      color: '#1f2937',
                      fontWeight: '600'
                    }}>
                      {selectedProduct.condition}
                    </div>
                  </div>
                )}
                {selectedProduct.materials_used && (
                  <div>
                    <div style={{
                      fontSize: '0.75rem',
                      color: '#6b7280',
                      marginBottom: '0.25rem',
                      fontWeight: '600'
                    }}>
                      Materials Used
                    </div>
                    <div style={{
                      fontSize: '1rem',
                      color: '#1f2937',
                      fontWeight: '600'
                    }}>
                      {selectedProduct.materials_used}
                    </div>
                  </div>
                )}
              </div>

              <button
                style={{
                  width: '100%',
                  padding: '1rem',
                  background: '#88844D',
                  color: 'white',
                  border: 'none',
                  borderRadius: '12px',
                  fontSize: '1.125rem',
                  fontWeight: '700',
                  cursor: 'pointer',
                  transition: 'background 0.2s'
                }}
                onMouseOver={(e) => e.currentTarget.style.background = '#6d6a3d'}
                onMouseOut={(e) => e.currentTarget.style.background = '#88844D'}
              >
                💬 Contact Artisan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default RealProductsGallery;