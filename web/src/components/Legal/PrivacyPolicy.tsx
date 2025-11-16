import React from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './Legal.module.css';

const PrivacyPolicy: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className={styles.container}>
      {/* Header */}
      <header className={styles.header}>
        <button 
          className={styles.backButton}
          onClick={() => navigate('/')}
        >
          <span className="material-symbols-outlined">arrow_back</span>
        </button>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Privacy Policy</h1>
        </div>
        <div className={styles.headerSpacer}></div>
      </header>

      {/* Content */}
      <div className={styles.content}>
        <div className={styles.section}>
          <p className={styles.paragraph}>
            At Junk & Gems, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your data when you use our mobile application and services.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>1. Information We Collect</h2>
          
          <h3 className={styles.subsectionTitle}>1.1 Personal Information</h3>
          <p className={styles.paragraph}>When you register for an account, we collect:</p>
          <ul className={styles.list}>
            <li>Name and email address</li>
            <li>Phone number (optional)</li>
            <li>Profile picture (optional)</li>
            <li>Location information (for material exchange purposes)</li>
            <li>Payment information (processed securely through third-party providers)</li>
          </ul>

          <h3 className={styles.subsectionTitle}>1.2 Content You Provide</h3>
          <ul className={styles.list}>
            <li>Material listings (descriptions, photos, categories)</li>
            <li>Product listings for upcycled items</li>
            <li>Messages and communications with other users</li>
            <li>Reviews and ratings</li>
            <li>Photos and videos you upload</li>
          </ul>

          <h3 className={styles.subsectionTitle}>1.3 Automatically Collected Information</h3>
          <ul className={styles.list}>
            <li>Device information (type, operating system, unique identifiers)</li>
            <li>App usage data and analytics</li>
            <li>IP address and general location data</li>
            <li>Log data (crash reports, performance metrics)</li>
          </ul>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>2. How We Use Your Information</h2>
          <p className={styles.paragraph}>We use your information to:</p>
          <ul className={styles.list}>
            <li>Provide and maintain the App's functionality</li>
            <li>Facilitate material donations and exchanges between users</li>
            <li>Process transactions for upcycled products</li>
            <li>Manage your Gem rewards and account</li>
            <li>Send notifications about your account and activities</li>
            <li>Improve and personalize your experience</li>
            <li>Prevent fraud and enhance security</li>
            <li>Comply with legal obligations</li>
            <li>Communicate updates, promotions, and news (with your consent)</li>
          </ul>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>3. Information Sharing and Disclosure</h2>
          
          <h3 className={styles.subsectionTitle}>3.1 With Other Users</h3>
          <p className={styles.paragraph}>
            When you list materials or products, your profile information (name, profile picture) and listing details are visible to other users. Messages you send through the App are shared with recipients.
          </p>

          <h3 className={styles.subsectionTitle}>3.2 With Service Providers</h3>
          <p className={styles.paragraph}>
            We share information with third-party service providers who help us operate the App, including:
          </p>
          <ul className={styles.list}>
            <li>Cloud storage providers</li>
            <li>Payment processors</li>
            <li>Analytics services</li>
            <li>Customer support tools</li>
          </ul>

          <h3 className={styles.subsectionTitle}>3.3 Legal Requirements</h3>
          <p className={styles.paragraph}>
            We may disclose your information if required by law, court order, or government request, or to protect the rights, property, and safety of Junk & Gems, our users, or others.
          </p>

          <h3 className={styles.subsectionTitle}>3.4 Business Transfers</h3>
          <p className={styles.paragraph}>
            In the event of a merger, acquisition, or sale of assets, your information may be transferred to the acquiring entity.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>4. Data Security</h2>
          <p className={styles.paragraph}>
            We implement industry-standard security measures to protect your information, including:
          </p>
          <ul className={styles.list}>
            <li>Encryption of data in transit and at rest</li>
            <li>Secure authentication protocols</li>
            <li>Regular security audits and updates</li>
            <li>Access controls and monitoring</li>
          </ul>
          <p className={styles.paragraph}>
            However, no method of transmission over the internet is 100% secure. While we strive to protect your data, we cannot guarantee absolute security.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>5. Your Rights and Choices</h2>
          
          <h3 className={styles.subsectionTitle}>5.1 Access and Update</h3>
          <p className={styles.paragraph}>
            You can access and update your account information at any time through the App's settings.
          </p>

          <h3 className={styles.subsectionTitle}>5.2 Data Deletion</h3>
          <p className={styles.paragraph}>
            You may request deletion of your account and associated data by contacting us at support@junkandgems.com. Some information may be retained as required by law or for legitimate business purposes.
          </p>

          <h3 className={styles.subsectionTitle}>5.3 Communication Preferences</h3>
          <p className={styles.paragraph}>
            You can opt out of promotional emails by following the unsubscribe link. You cannot opt out of essential service communications.
          </p>

          <h3 className={styles.subsectionTitle}>5.4 Location Data</h3>
          <p className={styles.paragraph}>
            You can control location permissions through your device settings. Disabling location services may limit certain App features.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>6. Children's Privacy</h2>
          <p className={styles.paragraph}>
            Junk & Gems is not intended for persons under 18 years of age. We do not knowingly collect personal information from children. If we discover that a child has provided us with personal information, we will delete it promptly.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>7. Third-Party Services</h2>
          <p className={styles.paragraph}>
            The App may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>8. International Data Transfers</h2>
          <p className={styles.paragraph}>
            Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>9. Data Retention</h2>
          <p className={styles.paragraph}>
            We retain your information for as long as your account is active or as needed to provide services. We may retain certain information after account closure for legal compliance, dispute resolution, and fraud prevention.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>10. Cookies and Tracking Technologies</h2>
          <p className={styles.paragraph}>
            We use cookies and similar technologies to enhance your experience, analyze usage patterns, and personalize content. You can manage cookie preferences through your device or browser settings.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>11. Changes to This Privacy Policy</h2>
          <p className={styles.paragraph}>
            We may update this Privacy Policy from time to time. We will notify you of significant changes through the App or via email. Your continued use of the App after changes indicates acceptance of the updated policy.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>12. Contact Us</h2>
          <p className={styles.paragraph}>
            If you have questions, concerns, or requests regarding this Privacy Policy or your personal information, please contact us:
          </p>
          <p className={styles.paragraph}>
            Email: privacy@junkandgems.com<br />
            Support: support@junkandgems.com<br />
            Address: Maseru, Lesotho
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>13. Your Consent</h2>
          <p className={styles.paragraph}>
            By using Junk & Gems, you consent to the collection, use, and sharing of your information as described in this Privacy Policy.
          </p>
        </div>

        <div className={styles.lastUpdated}>
          Last updated: {new Date().toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          })}
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicy;