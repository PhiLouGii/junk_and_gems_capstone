import React from 'react';
import styles from './LearnMore.module.css';
import { useNavigate } from 'react-router-dom';
import backgroundImage from '../../assets/background.jpg';

interface SafetyItemProps {
  icon: string;
  title: string;
  text: string;
}

const SafetyItem: React.FC<SafetyItemProps> = ({ icon, title, text }) => (
  <li className={styles.listItem}>
    <span className="material-symbols-outlined">{icon}</span>
    <span><strong>{title}</strong> {text}</span>
  </li>
);

const LearnMore: React.FC = () => {
  const navigate = useNavigate();
  return (
    <div className={styles.container}>
      {/* Hero Section */}
      <div 
        className={styles.hero}
        style={{
          backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.2) 0%, rgba(0, 0, 0, 0.5) 100%), url(${backgroundImage})`
        }}
      >
        <div className={styles.heroContent}>
          <h1 className={styles.heroTitle}>Turning Trash Into Treasure, Together</h1>
          <p className={styles.heroSubtitle}>
            A community where waste finds new purpose and creativity meets sustainability.
          </p>
        </div>
      </div>

      <main className={styles.main}>
        {/* How It Works Section */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>How Junk & Gems Works</h2>
          <div className={styles.grid3}>
            <div className={styles.card}>
              <span className="material-symbols-outlined">photo_camera</span>
              <h3>List Unwanted Materials</h3>
              <p>Easily photograph and list materials you no longer need. Provide a brief description and location for potential recipients.</p>
            </div>
            <div className={styles.card}>
              <span className="material-symbols-outlined">search</span>
              <h3>Browse Available Treasures</h3>
              <p>Explore a diverse range of materials listed by other community members. Use filters to find exactly what you need for your next project.</p>
            </div>
            <div className={styles.card}>
              <span className="material-symbols-outlined">handshake</span>
              <h3>Arrange Pickup</h3>
              <p>Once you've found a match, connect with the contributor to arrange a convenient pickup time and location.</p>
            </div>
          </div>
        </section>

        {/* Benefits for Contributors Section */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Got Materials to Share?</h2>
          <div className={styles.grid5}>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">delete</span>
              <h3>Clear clutter responsibly</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">palette</span>
              <h3>Support local artisans</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">recycling</span>
              <h3>Reduce landfill waste</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">groups</span>
              <h3>Build community</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">monitoring</span>
              <h3>Track environmental impact</h3>
            </div>
          </div>
        </section>

        {/* Benefits for Recipients Section */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Find Your Next Masterpiece</h2>
          <div className={styles.grid5}>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">diamond</span>
              <h3>Discover free materials</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">savings</span>
              <h3>Reduce project costs</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">eco</span>
              <h3>Create sustainably</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">connect_without_contact</span>
              <h3>Connect with sources</h3>
            </div>
            <div className={styles.benefitCard}>
              <span className="material-symbols-outlined">brush</span>
              <h3>Showcase your work</h3>
            </div>
          </div>
        </section>

        {/* Stats Section */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Join Our Sustainable Movement</h2>
          <div className={styles.grid4}>
            <div className={styles.statCard}>
              <p className={styles.statNumber}>150+</p>
              <p className={styles.statLabel}>tons saved</p>
            </div>
            <div className={styles.statCard}>
              <p className={styles.statNumber}>500+</p>
              <p className={styles.statLabel}>exchanges</p>
            </div>
            <div className={styles.statCard}>
              <p className={styles.statNumber}>200+</p>
              <p className={styles.statLabel}>artisans</p>
            </div>
            <div className={styles.statCard}>
              <p className={styles.statNumber}>50+</p>
              <p className={styles.statLabel}>communities</p>
            </div>
          </div>
        </section>

        {/* Safety & Rules Section */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Safe & Respectful Exchanges</h2>
          <div className={styles.safetyGrid}>
            <div>
              <h3 className={styles.safetyTitle}>Safety Tips</h3>
              <ul className={styles.list}>
                <SafetyItem icon="location_on" title="Meet in public:" text="Choose a well-lit, public location." />
                <SafetyItem icon="group" title="Bring a friend:" text="If possible, have someone with you." />
                <SafetyItem icon="visibility" title="Inspect items:" text="Check materials before accepting them." />
                <SafetyItem icon="admin_panel_settings" title="Trust instincts:" text="Cancel if something feels off." />
              </ul>
            </div>
            <div>
              <h3 className={styles.safetyTitle}>Community Rules</h3>
              <ul className={styles.list}>
                <SafetyItem icon="verified" title="Be honest:" text="Accurately describe materials." />
                <SafetyItem icon="chat" title="Communicate clearly:" text="Be prompt and responsive." />
                <SafetyItem icon="schedule" title="Respect time:" text="Arrive on time for meetups." />
                <SafetyItem icon="dangerous" title="No hazardous materials:" text="Do not list unsafe items." />
              </ul>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className={styles.ctaSection}>
          <div className={styles.ctaButtons}>
            <button className={styles.primaryButton}>Join the Movement</button>
            <button 
          className={styles.secondaryButton}
          onClick={() => navigate('/browse-materials')}
        >
          Browse Available Materials
        </button>
            <button className={styles.secondaryButton}>Upcycled Products Galllery</button>
          </div>
        </section>
      </main>
    </div>
  );
};

export default LearnMore;