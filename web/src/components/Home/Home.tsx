import React, { useState, useEffect } from 'react';

const EnhancedLandingPage = () => {
  const [scrollY, setScrollY] = useState(0);
  const [showDownloadModal, setShowDownloadModal] = useState(false);
  const [stats, setStats] = useState({ tons: 0, exchanges: 0, artisans: 0 });
const [hoveredFeature, setHoveredFeature] = useState<number | null>(null);
const [hoveredButton, setHoveredButton] = useState<string | null>(null);

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const duration = 2000;
    const steps = 60;
    const interval = duration / steps;
    
    const targets = { tons: 150, exchanges: 500, artisans: 200 };
    let currentStep = 0;

    const timer = setInterval(() => {
      currentStep++;
      const progress = currentStep / steps;
      
      setStats({
        tons: Math.floor(targets.tons * progress),
        exchanges: Math.floor(targets.exchanges * progress),
        artisans: Math.floor(targets.artisans * progress)
      });

      if (currentStep >= steps) clearInterval(timer);
    }, interval);

    return () => clearInterval(timer);
  }, []);

  const features = [
    {
      icon: '♻️',
      title: 'Donate Materials',
      description: 'Share unwanted items with artisans who need them',
      gradient: 'linear-gradient(135deg, #4ade80 0%, #059669 100%)'
    },
    {
      icon: '✨',
      title: 'Shop Upcycled Art',
      description: 'Discover unique creations from local artisans',
      gradient: 'linear-gradient(135deg, #c084fc 0%, #db2777 100%)'
    },
    {
      icon: '⭐',
      title: 'Earn Gems',
      description: 'Get rewarded for every sustainable action',
      gradient: 'linear-gradient(135deg, #fbbf24 0%, #ea580c 100%)'
    },
    {
      icon: '👥',
      title: 'Build Community',
      description: 'Connect with like-minded eco-warriors',
      gradient: 'linear-gradient(135deg, #60a5fa 0%, #06b6d4 100%)'
    },
    {
      icon: '📦',
      title: 'Local Exchanges',
      description: 'Find materials and artisans near you',
      gradient: 'linear-gradient(135deg, #f87171 0%, #fb7185 100%)'
    },
    {
      icon: '📈',
      title: 'Track Impact',
      description: 'See your environmental contribution grow',
      gradient: 'linear-gradient(135deg, #818cf8 0%, #a855f7 100%)'
    }
  ];

  const testimonials = [
    {
      name: 'Limakatso L.',
      role: 'Member',
      text: 'It is from this app I can now get materials for free to create my art pieces.',
    },
    {
      name: 'Mahloli M.',
      role: 'Member',
      text: 'Love seeing my old items transformed into beautiful art pieces!',
    },
    {
      name: 'Deborah P.',
      role: 'Member',
      text: 'The gem rewards make sustainability fun and engaging',
    }
  ];

  const impactMetrics = [
    { value: stats.tons, label: 'Tons Saved', icon: '♻️', suffix: '+' },
    { value: stats.exchanges, label: 'Exchanges', icon: '🤝', suffix: '+' },
    { value: stats.artisans, label: 'Artisans', icon: '🎨', suffix: '+' },
    { value: 50, label: 'Communities', icon: '🌍', suffix: '+' }
  ];

  return (
    <div style={{ minHeight: '100vh', background: 'linear-gradient(180deg, #f9fafb 0%, #ffffff 100%)', fontFamily: 'system-ui, -apple-system, sans-serif' }}>
      {/* Floating Header */}
      <nav style={{
        position: 'fixed',
        top: 0,
        width: '100%',
        background: 'rgba(255, 255, 255, 0.8)',
        backdropFilter: 'blur(12px)',
        zIndex: 50,
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '0 24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', height: '64px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{
                width: '40px',
                height: '40px',
                background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                borderRadius: '12px',
                padding: '8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <img src="/junk_and_gems_logo.jpg" alt="Junk & Gems Logo" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
              </div>
              <span style={{
                fontSize: '20px',
                fontWeight: 'bold',
                background: 'linear-gradient(90deg, #059669 0%, #10b981 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent'
              }}>
                Junk & Gems
              </span>
            </div>
            <button
              onClick={() => setShowDownloadModal(true)}
              style={{
                background: 'linear-gradient(90deg, #10b981 0%, #059669 100%)',
                color: 'white',
                padding: '8px 24px',
                borderRadius: '8px',
                fontWeight: '600',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                boxShadow: hoveredButton === 'nav' ? '0 10px 25px rgba(16, 185, 129, 0.3)' : '0 4px 6px rgba(0,0,0,0.1)',
                transform: hoveredButton === 'nav' ? 'translateY(-2px)' : 'translateY(0)',
                transition: 'all 0.3s'
              }}
              onMouseEnter={() => setHoveredButton('nav')}
              onMouseLeave={() => setHoveredButton(null)}
            >
              <span>📱</span>
              <span>Download</span>
            </button>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section style={{ position: 'relative', paddingTop: '128px', paddingBottom: '80px', padding: '128px 16px 80px', overflow: 'hidden' }}>
        {/* Animated Background */}
        <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
          <div style={{
            position: 'absolute',
            top: '80px',
            left: '40px',
            width: '288px',
            height: '288px',
            background: '#bbf7d0',
            borderRadius: '50%',
            filter: 'blur(64px)',
            opacity: 0.3,
            transform: `translateY(${scrollY * 0.3}px)`,
            animation: 'blob 7s infinite'
          }} />
          <div style={{
            position: 'absolute',
            top: '160px',
            right: '40px',
            width: '288px',
            height: '288px',
            background: '#a7f3d0',
            borderRadius: '50%',
            filter: 'blur(64px)',
            opacity: 0.3,
            transform: `translateY(${scrollY * 0.2}px)`,
            animation: 'blob 7s infinite 2s'
          }} />
          <div style={{
            position: 'absolute',
            bottom: '-32px',
            left: '50%',
            width: '288px',
            height: '288px',
            background: '#86efac',
            borderRadius: '50%',
            filter: 'blur(64px)',
            opacity: 0.3,
            transform: `translateY(${scrollY * 0.4}px)`,
            animation: 'blob 7s infinite 4s'
          }} />
        </div>

        <div style={{ maxWidth: '1280px', margin: '0 auto', position: 'relative', zIndex: 1 }}>
          <div style={{ textAlign: 'center' }}>
            {/* Badge */}
            <div style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              background: 'rgba(255, 255, 255, 0.8)',
              backdropFilter: 'blur(10px)',
              padding: '8px 16px',
              borderRadius: '20px',
              boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
              border: '1px solid #d1fae5',
              marginBottom: '24px'
            }}>
              <span style={{
                width: '8px',
                height: '8px',
                background: '#10b981',
                borderRadius: '50%',
                animation: 'pulse 2s infinite'
              }} />
              <span style={{ fontSize: '14px', fontWeight: '600', color: '#374151' }}>🌍 Turning Waste Into Opportunity</span>
            </div>

            {/* Main Heading */}
            <h1 style={{
              fontSize: 'clamp(2.5rem, 8vw, 4.5rem)',
              fontWeight: '800',
              color: '#111827',
              lineHeight: '1.1',
              marginBottom: '24px'
            }}>
              Transform Waste Into
              <span style={{
                display: 'block',
                background: 'linear-gradient(90deg, #10b981 0%, #059669 50%, #10b981 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundSize: '200% 200%',
                animation: 'gradient 3s ease infinite'
              }}>
                Treasures
              </span>
            </h1>

            {/* Subheading */}
            <p style={{
              fontSize: 'clamp(1.25rem, 3vw, 1.75rem)',
              color: '#4b5563',
              maxWidth: '768px',
              margin: '0 auto 40px',
              lineHeight: '1.6'
            }}>
              Connect donors and artisans in a sustainable ecosystem. Share materials, create art, earn rewards.
            </p>

            {/* CTA Buttons */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '16px', paddingTop: '16px', flexWrap: 'wrap' }}>
              <button
                onClick={() => setShowDownloadModal(true)}
                style={{
                  background: 'linear-gradient(90deg, #10b981 0%, #059669 100%)',
                  color: 'white',
                  padding: '16px 32px',
                  borderRadius: '12px',
                  fontWeight: '700',
                  fontSize: '18px',
                  border: 'none',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  boxShadow: hoveredButton === 'main' ? '0 20px 40px rgba(16, 185, 129, 0.4)' : '0 10px 25px rgba(16, 185, 129, 0.3)',
                  transform: hoveredButton === 'main' ? 'scale(1.05)' : 'scale(1)',
                  transition: 'all 0.3s'
                }}
                onMouseEnter={() => setHoveredButton('main')}
                onMouseLeave={() => setHoveredButton(null)}
              >
                <span style={{ fontSize: '24px' }}>📱</span>
                <span>Download for Android</span>
                <span style={{ transform: hoveredButton === 'main' ? 'translateX(4px)' : 'translateX(0)', transition: 'transform 0.3s' }}>→</span>
              </button>
              
              <a
                href="/learn-more"
                style={{
                  background: 'white',
                  color: '#374151',
                  padding: '16px 32px',
                  borderRadius: '12px',
                  fontWeight: '700',
                  fontSize: '18px',
                  textDecoration: 'none',
                  border: '2px solid #e5e7eb',
                  boxShadow: hoveredButton === 'learn' ? '0 10px 25px rgba(0,0,0,0.15)' : '0 4px 6px rgba(0,0,0,0.1)',
                  transition: 'all 0.3s',
                  borderColor: hoveredButton === 'learn' ? '#10b981' : '#e5e7eb'
                }}
                onMouseEnter={() => setHoveredButton('learn')}
                onMouseLeave={() => setHoveredButton(null)}
              >
                Learn More
              </a>
            </div>

            {/* Trust Indicators */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '24px', paddingTop: '32px', fontSize: '14px', color: '#6b7280', flexWrap: 'wrap' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ color: '#10b981', fontSize: '20px' }}>✓</span>
                <span>100% Free</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ color: '#10b981', fontSize: '20px' }}>✓</span>
                <span>No Ads</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ color: '#10b981', fontSize: '20px' }}>✓</span>
                <span>Secure</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Live Impact Stats */}
      <section style={{ padding: '64px 16px', background: 'linear-gradient(90deg, #10b981 0%, #059669 100%)' }}>
        <div style={{ maxWidth: '1280px', margin: '0 auto' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: '32px' }}>
            {impactMetrics.map((metric, index) => (
              <div key={index} style={{ textAlign: 'center', color: 'white' }}>
                <div style={{ fontSize: '48px', marginBottom: '8px' }}>{metric.icon}</div>
                <div style={{ fontSize: 'clamp(2rem, 5vw, 3rem)', fontWeight: 'bold', marginBottom: '8px' }}>
                  {metric.value}{metric.suffix}
                </div>
                <div style={{ fontSize: 'clamp(0.875rem, 2vw, 1rem)', opacity: 0.9, fontWeight: '500' }}>
                  {metric.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section style={{ padding: '80px 16px' }}>
        <div style={{ maxWidth: '1280px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', marginBottom: '64px' }}>
            <h2 style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: 'bold', color: '#111827', marginBottom: '16px' }}>
              Why Junk & Gems?
            </h2>
            <p style={{ fontSize: '20px', color: '#6b7280', maxWidth: '672px', margin: '0 auto' }}>
              A complete ecosystem for sustainable material exchange and upcycled creativity
            </p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '32px' }}>
            {features.map((feature, index) => (
              <div
                key={index}
                style={{
                  background: 'white',
                  borderRadius: '16px',
                  padding: '32px',
                  boxShadow: hoveredFeature === index ? '0 20px 40px rgba(16, 185, 129, 0.2)' : '0 4px 20px rgba(0,0,0,0.08)',
                  transition: 'all 0.3s',
                  transform: hoveredFeature === index ? 'translateY(-8px)' : 'translateY(0)',
                  border: '1px solid #f3f4f6',
                  cursor: 'pointer'
                }}
                onMouseEnter={() => setHoveredFeature(index)}
                onMouseLeave={() => setHoveredFeature(null)}
              >
                <div style={{
                  width: '64px',
                  height: '64px',
                  background: feature.gradient,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '32px',
                  color: 'white',
                  marginBottom: '24px',
                  transform: hoveredFeature === index ? 'scale(1.1)' : 'scale(1)',
                  transition: 'transform 0.3s'
                }}>
                  {feature.icon}
                </div>
                <h3 style={{ fontSize: '24px', fontWeight: 'bold', color: '#111827', marginBottom: '12px' }}>
                  {feature.title}
                </h3>
                <p style={{ color: '#6b7280', lineHeight: '1.6' }}>
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section style={{ padding: '80px 16px', background: 'linear-gradient(180deg, #f9fafb 0%, #ffffff 100%)' }}>
        <div style={{ maxWidth: '1000px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', marginBottom: '64px' }}>
            <h2 style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: 'bold', color: '#111827', marginBottom: '16px' }}>
              Get Started in 3 Easy Steps
            </h2>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '48px' }}>
            {[
              { num: '1', title: 'Download & Sign Up', desc: 'Get the app and create your free account in seconds', color: 'linear-gradient(135deg, #4ade80 0%, #10b981 100%)' },
              { num: '2', title: 'Explore or List', desc: 'Browse available materials or list items you want to donate', color: 'linear-gradient(135deg, #10b981 0%, #14b8a6 100%)' },
              { num: '3', title: 'Connect & Exchange', desc: 'Arrange pickup, earn gems, and make an impact!', color: 'linear-gradient(135deg, #14b8a6 0%, #06b6d4 100%)' }
            ].map((step, index) => (
              <div key={index} style={{ display: 'flex', alignItems: 'center', gap: '32px', flexWrap: 'wrap' }}>
                <div style={{
                  minWidth: '80px',
                  height: '80px',
                  background: step.color,
                  borderRadius: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '32px',
                  fontWeight: '800',
                  color: 'white',
                  boxShadow: '0 8px 24px rgba(16, 185, 129, 0.3)',
                  flexShrink: 0
                }}>
                  {step.num}
                </div>
                <div style={{ flex: 1, background: 'white', borderRadius: '16px', padding: '32px', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}>
                  <h3 style={{ fontSize: '24px', fontWeight: 'bold', color: '#111827', marginBottom: '8px' }}>{step.title}</h3>
                  <p style={{ fontSize: '18px', color: '#6b7280', lineHeight: '1.6' }}>{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section style={{ padding: '80px 16px' }}>
        <div style={{ maxWidth: '1280px', margin: '0 auto' }}>
          <div style={{ textAlign: 'center', marginBottom: '64px' }}>
            <h2 style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: 'bold', color: '#111827', marginBottom: '16px' }}>
              Loved by Our Community
            </h2>
            <p style={{ fontSize: '20px', color: '#6b7280' }}>See what people are saying about Junk & Gems</p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '32px' }}>
            {testimonials.map((testimonial, index) => (
              <div key={index} style={{ background: 'white', borderRadius: '16px', padding: '32px', boxShadow: '0 4px 20px rgba(0,0,0,0.08)', transition: 'box-shadow 0.3s' }}>
                <div style={{ display: 'flex', alignItems: 'center', marginBottom: '16px' }}>
                  {[...Array(5)].map((_, i) => (
                    <span key={i} style={{ color: '#fbbf24', fontSize: '20px' }}>⭐</span>
                  ))}
                </div>
                <p style={{ color: '#374151', marginBottom: '24px', lineHeight: '1.6', fontStyle: 'italic' }}>"{testimonial.text}"</p>
                <div>
                  <div style={{ fontWeight: 'bold', color: '#111827' }}>{testimonial.name}</div>
                  <div style={{ fontSize: '14px', color: '#9ca3af' }}>{testimonial.role}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section style={{ padding: '80px 16px', background: 'linear-gradient(135deg, #10b981 0%, #059669 50%, #10b981 100%)', position: 'relative', overflow: 'hidden' }}>
        <div style={{
          position: 'absolute',
          inset: 0,
          backgroundImage: 'url("data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'0.1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
          opacity: 0.1
        }} />
        
        <div style={{ maxWidth: '896px', margin: '0 auto', textAlign: 'center', position: 'relative', zIndex: 1 }}>
          <div style={{ fontSize: '64px', marginBottom: '24px' }}>🚀</div>
          <h2 style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: 'bold', color: 'white', marginBottom: '24px' }}>
            Ready to Join the Movement?
          </h2>
          <p style={{ fontSize: '20px', color: 'rgba(255,255,255,0.9)', marginBottom: '32px', lineHeight: '1.6' }}>
            Download Junk & Gems now and start making a difference today!
          </p>
          
          <button
            onClick={() => setShowDownloadModal(true)}
            style={{
              background: 'white',
              color: '#059669',
              padding: '20px 40px',
              borderRadius: '12px',
              fontWeight: '700',
              fontSize: '20px',
              border: 'none',
              cursor: 'pointer',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '12px',
              boxShadow: hoveredButton === 'cta' ? '0 25px 50px rgba(0,0,0,0.3)' : '0 20px 40px rgba(0,0,0,0.2)',
              transform: hoveredButton === 'cta' ? 'scale(1.05)' : 'scale(1)',
              transition: 'all 0.3s'
            }}
            onMouseEnter={() => setHoveredButton('cta')}
            onMouseLeave={() => setHoveredButton(null)}
          >
            <span style={{ fontSize: '28px' }}>📱</span>
            <span>Download for Android</span>
          </button>

          <p style={{ color: 'rgba(255,255,255,0.8)', marginTop: '24px', fontSize: '14px' }}>
            🍎 iOS version coming soon!
          </p>
        </div>
      </section>

      {/* Download Modal */}
      {showDownloadModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.7)',
            backdropFilter: 'blur(8px)',
            zIndex: 50,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '16px',
            animation: 'fadeIn 0.3s ease-out'
          }}
          onClick={() => setShowDownloadModal(false)}
        >
          <div
            style={{
              background: 'white',
              borderRadius: '24px',
              maxWidth: '448px',
              width: '100%',
              boxShadow: '0 25px 50px rgba(0,0,0,0.3)',
              animation: 'scaleIn 0.3s ease-out'
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ padding: '32px' }}>
              <button
                onClick={() => setShowDownloadModal(false)}
                style={{
                  float: 'right',
                  background: 'transparent',
                  border: 'none',
                  fontSize: '24px',
                  cursor: 'pointer',
                  color: '#9ca3af',
                  transition: 'color 0.2s'
                }}
              >
                ✕
              </button>

              <div style={{ textAlign: 'center' }}>
                <div style={{ fontSize: '64px', marginBottom: '16px' }}>📱</div>
                <h3 style={{ fontSize: '28px', fontWeight: 'bold', color: '#111827', marginBottom: '12px' }}>
                  Download Junk & Gems
                </h3>
                <p style={{ color: '#6b7280', marginBottom: '24px', lineHeight: '1.6' }}>
                  Get the latest version of our Android app and start your sustainable journey today!
                </p>

                <div style={{
                  background: 'linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%)',
                  borderRadius: '16px',
                  padding: '24px',
                  marginBottom: '24px'
                }}>
                  <div style={{ fontSize: '14px', color: '#6b7280', marginBottom: '16px' }}>
                    Version 1.0.0 • 25 MB
                  </div>
                  <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', flexWrap: 'wrap' }}>
                    <span style={{
                      padding: '8px 16px',
                      background: '#dbeafe',
                      color: '#1e40af',
                      borderRadius: '20px',
                      fontSize: '12px',
                      fontWeight: '600'
                    }}>✓ No Ads</span>
                    <span style={{
                      padding: '8px 16px',
                      background: '#fed7aa',
                      color: '#9a3412',
                      borderRadius: '20px',
                      fontSize: '12px',
                      fontWeight: '600'
                    }}>✓ Free</span>
                  </div>
                </div>

                <a
                  href="/junk-and-gems.apk"
                  download="junk-and-gems.apk"
                  style={{
                    display: 'block',
                    width: '100%',
                    background: 'linear-gradient(90deg, #10b981 0%, #059669 100%)',
                    color: 'white',
                    padding: '16px',
                    borderRadius: '12px',
                    fontWeight: '700',
                    fontSize: '18px',
                    textDecoration: 'none',
                    boxShadow: '0 10px 25px rgba(16, 185, 129, 0.3)',
                    transition: 'all 0.3s',
                    marginBottom: '24px'
                  }}
                >
                  ⬇️ Download APK Now
                </a>

                <div style={{
                  background: '#fffbeb',
                  border: '1px solid #fcd34d',
                  borderRadius: '12px',
                  padding: '16px',
                  textAlign: 'left'
                }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '8px' }}>
                    <span style={{ fontSize: '20px' }}>📌</span>
                    <div style={{ fontSize: '13px', color: '#374151', lineHeight: '1.5' }}>
                      <strong>Installation Note:</strong> You may need to enable "Install from Unknown Sources" in your Android settings.
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer style={{ background: '#111827', color: 'white', padding: '48px 16px' }}>
        <div style={{ maxWidth: '1280px', margin: '0 auto' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: '24px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{
                width: '48px',
                height: '48px',
                background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                borderRadius: '12px',
                padding: '8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <img src="/junk_and_gems_logo.jpg" alt="Junk & Gems Logo" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
              </div>
              <span style={{ fontSize: '24px', fontWeight: 'bold' }}>Junk & Gems</span>
            </div>
            <p style={{ color: '#9ca3af', maxWidth: '448px' }}>
              Turning trash into Treasure, together.
            </p>
            
            <div style={{ display: 'flex', gap: '32px', fontSize: '14px', flexWrap: 'wrap', justifyContent: 'center' }}>
              <a href="#" style={{ color: '#9ca3af', textDecoration: 'none', transition: 'color 0.2s' }}>About</a>
              <a href="#" style={{ color: '#9ca3af', textDecoration: 'none', transition: 'color 0.2s' }}>Contact</a>
              <a href="#" style={{ color: '#9ca3af', textDecoration: 'none', transition: 'color 0.2s' }}>Privacy</a>
              <a href="#" style={{ color: '#9ca3af', textDecoration: 'none', transition: 'color 0.2s' }}>Terms</a>
            </div>
            
            <div style={{ color: '#6b7280', fontSize: '14px', paddingTop: '24px', borderTop: '1px solid #374151', width: '100%' }}>
              © 2025 Junk & Gems. All rights reserved.
            </div>
          </div>
        </div>
      </footer>

      <style>{`
        @keyframes gradient {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }
        
        @keyframes blob {
          0%, 100% { transform: translate(0, 0) scale(1); }
          25% { transform: translate(20px, -50px) scale(1.1); }
          50% { transform: translate(-20px, 20px) scale(0.9); }
          75% { transform: translate(50px, 50px) scale(1.05); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.5; }
        }
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        @keyframes scaleIn {
          from { transform: scale(0.9); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  );
};

export default EnhancedLandingPage;
                      