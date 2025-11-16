import React, { useState, useEffect } from 'react';

const EnhancedLandingPage = () => {
  const [scrollY, setScrollY] = useState(0);
  const [showDownloadModal, setShowDownloadModal] = useState(false);
  const [stats, setStats] = useState({ tons: 0, exchanges: 0, artisans: 0 });

  // Parallax scroll effect
  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Animated counter effect
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
      gradient: 'from-green-400 to-emerald-600'
    },
    {
      icon: '✨',
      title: 'Shop Upcycled Art',
      description: 'Discover unique creations from local artisans',
      gradient: 'from-purple-400 to-pink-600'
    },
    {
      icon: '⭐',
      title: 'Earn Gems',
      description: 'Get rewarded for every sustainable action',
      gradient: 'from-yellow-400 to-orange-600'
    },
    {
      icon: '👥',
      title: 'Build Community',
      description: 'Connect with like-minded eco-warriors',
      gradient: 'from-blue-400 to-cyan-600'
    },
    {
      icon: '📦',
      title: 'Local Exchanges',
      description: 'Find materials and artisans near you',
      gradient: 'from-red-400 to-rose-600'
    },
    {
      icon: '📈',
      title: 'Track Impact',
      description: 'See your environmental contribution grow',
      gradient: 'from-indigo-400 to-purple-600'
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
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
      {/* Floating Header */}
      <nav className="fixed top-0 w-full bg-white/80 backdrop-blur-md z-50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl p-2 flex items-center justify-center">
                <img src="/junk_and_gems_logo.jpg" alt="Junk & Gems Logo" className="w-full h-full object-contain" />
            </div>
              <span className="text-xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                Junk & Gems
              </span>
            </div>
            <button
              onClick={() => setShowDownloadModal(true)}
              className="bg-gradient-to-r from-green-500 to-emerald-600 text-white px-6 py-2 rounded-lg font-semibold hover:shadow-lg transition-all duration-300 flex items-center space-x-2"
            >
              <span>📱</span>
              <span>Download</span>
            </button>
          </div>
        </div>
      </nav>

      {/* Hero Section with Parallax */}
      <section className="relative pt-32 pb-20 px-4 overflow-hidden">
        {/* Animated Background Elements */}
        <div className="absolute inset-0 overflow-hidden">
          <div 
            className="absolute top-20 left-10 w-72 h-72 bg-green-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob"
            style={{ transform: `translateY(${scrollY * 0.3}px)` }}
          />
          <div 
            className="absolute top-40 right-10 w-72 h-72 bg-emerald-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob animation-delay-2000"
            style={{ transform: `translateY(${scrollY * 0.2}px)` }}
          />
          <div 
            className="absolute -bottom-8 left-1/2 w-72 h-72 bg-green-300 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob animation-delay-4000"
            style={{ transform: `translateY(${scrollY * 0.4}px)` }}
          />
        </div>

        <div className="max-w-7xl mx-auto relative z-10">
          <div className="text-center space-y-8">
            {/* Badge */}
            <div className="inline-flex items-center space-x-2 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-full shadow-lg border border-green-100">
              <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
              <span className="text-sm font-semibold text-gray-700">🌍 Turning Waste Into Opportunity</span>
            </div>

            {/* Main Heading */}
            <h1 className="text-5xl sm:text-6xl md:text-7xl font-extrabold text-gray-900 leading-tight">
              Transform Waste Into
              <span className="block bg-gradient-to-r from-green-500 via-emerald-500 to-green-600 bg-clip-text text-transparent animate-gradient">
                Treasures
              </span>
            </h1>

            {/* Subheading */}
            <p className="text-xl sm:text-2xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              Connect donors and artisans in a sustainable ecosystem. Share materials, create art, earn rewards.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
              <button
                onClick={() => setShowDownloadModal(true)}
                className="group bg-gradient-to-r from-green-500 to-emerald-600 text-white px-8 py-4 rounded-xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all duration-300 flex items-center space-x-3 hover:scale-105"
              >
                <span className="text-2xl">📱</span>
                <span>Download for Android</span>
                <span className="group-hover:translate-x-1 transition-transform">→</span>
              </button>
              
              <a
                href="/learn-more"
                className="bg-white text-gray-700 px-8 py-4 rounded-xl font-bold text-lg shadow-lg hover:shadow-xl transition-all duration-300 border-2 border-gray-200 hover:border-green-500"
              >
                Learn More
              </a>
            </div>

            {/* Trust Indicators */}
            <div className="flex items-center justify-center space-x-6 pt-8 text-sm text-gray-600 flex-wrap gap-4">
              <div className="flex items-center space-x-2">
                <span className="text-green-500 text-xl">✓</span>
                <span>100% Free</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="text-green-500 text-xl">✓</span>
                <span>No Ads</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="text-green-500 text-xl">✓</span>
                <span>Secure</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Live Impact Stats */}
      <section className="py-16 px-4 bg-gradient-to-r from-green-500 to-emerald-600">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {impactMetrics.map((metric, index) => (
              <div key={index} className="text-center text-white">
                <div className="text-5xl mb-2">{metric.icon}</div>
                <div className="text-4xl md:text-5xl font-bold mb-2">
                  {metric.value}{metric.suffix}
                </div>
                <div className="text-sm md:text-base opacity-90 font-medium">
                  {metric.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
              Why Junk & Gems?
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              A complete ecosystem for sustainable material exchange and upcycled creativity
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="group bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100"
              >
                <div className={`w-16 h-16 bg-gradient-to-br ${feature.gradient} rounded-xl flex items-center justify-center text-white text-3xl mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  {feature.icon}
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-3">
                  {feature.title}
                </h3>
                <p className="text-gray-600 leading-relaxed">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 px-4 bg-gradient-to-b from-gray-50 to-white">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
              Get Started in 3 Easy Steps
            </h2>
          </div>

          <div className="space-y-12">
            {[
              { num: '1', title: 'Download & Sign Up', desc: 'Get the app and create your free account in seconds', color: 'from-green-400 to-emerald-500' },
              { num: '2', title: 'Explore or List', desc: 'Browse available materials or list items you want to donate', color: 'from-emerald-400 to-teal-500' },
              { num: '3', title: 'Connect & Exchange', desc: 'Arrange pickup, earn gems, and make an impact!', color: 'from-teal-400 to-cyan-500' }
            ].map((step, index) => (
              <div key={index} className="flex items-center gap-8">
                <div className={`hidden md:flex w-20 h-20 bg-gradient-to-br ${step.color} rounded-2xl items-center justify-center text-white text-3xl font-bold shadow-xl flex-shrink-0`}>
                  {step.num}
                </div>
                <div className="flex-1 bg-white rounded-2xl p-8 shadow-lg">
                  <div className="flex items-start gap-4">
                    <div className={`md:hidden w-12 h-12 bg-gradient-to-br ${step.color} rounded-xl flex items-center justify-center text-white text-xl font-bold flex-shrink-0`}>
                      {step.num}
                    </div>
                    <div>
                      <h3 className="text-2xl font-bold text-gray-900 mb-2">{step.title}</h3>
                      <p className="text-lg text-gray-600">{step.desc}</p>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
              Loved by Our Community
            </h2>
            <p className="text-xl text-gray-600">See what people are saying about Junk & Gems</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition-shadow duration-300">
                <div className="flex items-center mb-4">
                  {[...Array(5)].map((_, i) => (
                    <span key={i} className="text-yellow-400 text-xl">⭐</span>
                  ))}
                </div>
                <p className="text-gray-700 mb-6 leading-relaxed italic">"{testimonial.text}"</p>
                <div className="flex items-center space-x-3">
                  <div>
                    <div className="font-bold text-gray-900">{testimonial.name}</div>
                    <div className="text-sm text-gray-500">{testimonial.role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-20 px-4 bg-gradient-to-br from-green-500 via-emerald-500 to-green-600 relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmZmZmYiIGZpbGwtb3BhY2l0eT0iMC4xIj48cGF0aCBkPSJNMzYgMzR2LTRoLTJ2NGgtNHYyaDR2NGgydi00aDR2LTJoLTR6bTAtMzBWMGgtMnY0aC00djJoNHY0aDJWNmg0VjRoLTR6TTYgMzR2LTRINHY0SDB2Mmg0djRoMnYtNGg0di0ySDZ6TTYgNFYwSDR2NEgwdjJoNHY0aDJWNmg0VjRINnoiLz48L2c+PC9nPjwvc3ZnPg==')] opacity-10" />
        
        <div className="max-w-4xl mx-auto text-center relative z-10">
          <div className="text-6xl mb-6">🚀</div>
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
            Ready to Join the Movement?
          </h2>
          <p className="text-xl text-white/90 mb-8 leading-relaxed">
            Download Junk & Gems now and start making a difference today!
          </p>
          
          <button
            onClick={() => setShowDownloadModal(true)}
            className="bg-white text-green-600 px-10 py-5 rounded-xl font-bold text-xl shadow-2xl hover:shadow-3xl transition-all duration-300 inline-flex items-center space-x-3 hover:scale-105"
          >
            <span className="text-2xl">📱</span>
            <span>Download for Android</span>
          </button>

          <p className="text-white/80 mt-6 text-sm">
            🍎 iOS version coming soon!
          </p>
        </div>
      </section>

      {/* Download Modal */}
      {showDownloadModal && (
        <div
          className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fadeIn"
          onClick={() => setShowDownloadModal(false)}
        >
          <div
            className="bg-white rounded-3xl max-w-md w-full shadow-2xl animate-scaleIn"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-8">
              <button
                onClick={() => setShowDownloadModal(false)}
                className="float-right text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>

              <div className="text-center">
                <div className="text-6xl mb-4">📱</div>
                <h3 className="text-3xl font-bold text-gray-900 mb-3">
                  Download Junk & Gems
                </h3>
                <p className="text-gray-600 mb-6 leading-relaxed">
                  Get the latest version of our Android app and start your sustainable journey today!
                </p>

                <div className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-6 mb-6">
                  <div className="text-sm text-gray-600 mb-4">
                    Version 1.0.0 • 25 MB
                  </div>
                  <div className="flex gap-2 justify-center flex-wrap">
                    <span className="px-4 py-2 bg-green-100 text-green-700 rounded-full text-sm font-semibold">
                      ✓ Safe
                    </span>
                    <span className="px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold">
                      ✓ No Ads
                    </span>
                    <span className="px-4 py-2 bg-amber-100 text-amber-700 rounded-full text-sm font-semibold">
                      ✓ Free
                    </span>
                  </div>
                </div>

                <a
                  href="/junk-and-gems.apk"
                  download="junk-and-gems.apk"
                  className="block w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white py-4 rounded-xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105 mb-6"
                >
                  ⬇️ Download APK Now
                </a>

                <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 text-left">
                  <div className="flex items-start space-x-2">
                    <span className="text-xl">📌</span>
                    <div className="text-sm text-gray-700">
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
      <footer className="bg-gray-900 text-white py-12 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col items-center text-center space-y-6">
            <div className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl p-2 flex items-center justify-center">
                <img src="/junk_and_gems_logo.jpg" alt="Junk & Gems Logo" className="w-full h-full object-contain" />
            </div>
              <span className="text-2xl font-bold">Junk & Gems</span>
            </div>
            <p className="text-gray-400 max-w-md">
              Turning trash into Treasure, together.
            </p>
            
            <div className="flex space-x-8 text-sm flex-wrap justify-center gap-4">
              <a href="#" className="text-gray-400 hover:text-white transition-colors">About</a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Contact</a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Privacy</a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">Terms</a>
            </div>
            
            <div className="text-gray-500 text-sm pt-6 border-t border-gray-800 w-full">
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
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        @keyframes scaleIn {
          from { transform: scale(0.9); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
        
        .animate-gradient {
          background-size: 200% 200%;
          animation: gradient 3s ease infinite;
        }
        
        .animate-blob {
          animation: blob 7s infinite;
        }
        
        .animation-delay-2000 {
          animation-delay: 2s;
        }
        
        .animation-delay-4000 {
          animation-delay: 4s;
        }
        
        .animate-fadeIn {
          animation: fadeIn 0.3s ease-out;
        }
        
        .animate-scaleIn {
          animation: scaleIn 0.3s ease-out;
        }
      `}</style>
    </div>
  );
};

export default EnhancedLandingPage;