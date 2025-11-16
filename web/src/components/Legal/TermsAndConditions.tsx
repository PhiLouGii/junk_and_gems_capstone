import React from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './Legal.module.css';

const TermsAndConditions: React.FC = () => {
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
          <h1 className={styles.title}>Terms & Conditions</h1>
        </div>
        <div className={styles.headerSpacer}></div>
      </header>

      {/* Content */}
      <div className={styles.content}>
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>1. Acceptance of Terms</h2>
          <p className={styles.paragraph}>
            By accessing and using Junk & Gems ("the App"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>2. Description of Service</h2>
          <p className={styles.paragraph}>
            Junk & Gems is a platform that connects individuals who wish to donate recyclable materials with artisans who can transform these materials into upcycled products. The App also provides a marketplace for buying and selling these upcycled creations.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>3. User Accounts</h2>
          <h3 className={styles.subsectionTitle}>3.1 Registration</h3>
          <p className={styles.paragraph}>
            To use certain features of the App, you must register for an account. You agree to provide accurate, current, and complete information during the registration process.
          </p>
          
          <h3 className={styles.subsectionTitle}>3.2 Account Security</h3>
          <p className={styles.paragraph}>
            You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>4. User Conduct</h2>
          <p className={styles.paragraph}>You agree not to:</p>
          <ul className={styles.list}>
            <li>Post false, inaccurate, misleading, or defamatory content</li>
            <li>List hazardous materials or items prohibited by law</li>
            <li>Engage in fraudulent transactions</li>
            <li>Harass, threaten, or intimidate other users</li>
            <li>Violate any applicable laws or regulations</li>
            <li>Attempt to gain unauthorized access to the App or other users' accounts</li>
          </ul>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>5. Material Donations & Exchanges</h2>
          <h3 className={styles.subsectionTitle}>5.1 Donor Responsibilities</h3>
          <ul className={styles.list}>
            <li>Provide accurate descriptions and images of materials</li>
            <li>Ensure materials are safe and non-hazardous</li>
            <li>Honor scheduled pickup arrangements</li>
            <li>Obtain necessary permissions if donating materials from shared or rented properties</li>
          </ul>

          <h3 className={styles.subsectionTitle}>5.2 Recipient Responsibilities</h3>
          <ul className={styles.list}>
            <li>Inspect materials before accepting</li>
            <li>Arrive on time for scheduled pickups</li>
            <li>Treat donors with respect and courtesy</li>
          </ul>

          <h3 className={styles.subsectionTitle}>5.3 Safety Guidelines</h3>
          <p className={styles.paragraph}>
            Users are encouraged to meet in public places and take necessary precautions when exchanging materials. Junk & Gems is not responsible for disputes, injuries, or damages arising from material exchanges.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>6. Marketplace & Transactions</h2>
          <h3 className={styles.subsectionTitle}>6.1 Product Listings</h3>
          <p className={styles.paragraph}>
            Artisans may list upcycled products for sale. All listings must include accurate descriptions, clear images, and fair pricing.
          </p>

          <h3 className={styles.subsectionTitle}>6.2 Payments</h3>
          <p className={styles.paragraph}>
            Transactions are facilitated through the App's integrated payment system. Junk & Gems may charge a service fee on completed transactions.
          </p>

          <h3 className={styles.subsectionTitle}>6.3 Refunds & Returns</h3>
          <p className={styles.paragraph}>
            Refund and return policies are set by individual artisans. Buyers should review these policies before making a purchase. Disputes should be resolved directly between buyers and sellers.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>7. Gem Rewards System</h2>
          <p className={styles.paragraph}>
            Users earn "Gems" for participating in sustainable activities such as donating materials and purchasing upcycled products. Gems can be redeemed for rewards as specified in the App. Gems have no cash value and are non-transferable.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>8. Intellectual Property</h2>
          <p className={styles.paragraph}>
            All content, features, and functionality of the App are owned by Junk & Gems and are protected by international copyright, trademark, and other intellectual property laws.
          </p>
          <p className={styles.paragraph}>
            Users retain ownership of the content they post but grant Junk & Gems a license to use, display, and distribute such content through the App.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>9. Disclaimer of Warranties</h2>
          <p className={styles.paragraph}>
            The App is provided on an "as is" and "as available" basis. Junk & Gems makes no warranties, expressed or implied, regarding the App's operation or the information, content, materials, or products included on the App.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>10. Limitation of Liability</h2>
          <p className={styles.paragraph}>
            Junk & Gems shall not be liable for any damages arising from the use of or inability to use the App, including but not limited to direct, indirect, incidental, punitive, and consequential damages.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>11. Indemnification</h2>
          <p className={styles.paragraph}>
            You agree to indemnify and hold Junk & Gems harmless from any claims, damages, losses, liabilities, and expenses arising from your use of the App or violation of these Terms.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>12. Termination</h2>
          <p className={styles.paragraph}>
            Junk & Gems reserves the right to terminate or suspend your account at any time, with or without notice, for conduct that violates these Terms or is harmful to other users, us, or third parties.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>13. Changes to Terms</h2>
          <p className={styles.paragraph}>
            Junk & Gems reserves the right to modify these Terms at any time. Users will be notified of significant changes. Continued use of the App after changes constitutes acceptance of the new Terms.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>14. Governing Law</h2>
          <p className={styles.paragraph}>
            These Terms shall be governed by and construed in accordance with the laws of Lesotho, without regard to its conflict of law provisions.
          </p>
        </div>

        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>15. Contact Information</h2>
          <p className={styles.paragraph}>
            For questions about these Terms, please contact us at:
          </p>
          <p className={styles.paragraph}>
            Email: support@junkandgems.com<br />
            Address: Maseru, Lesotho
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

export default TermsAndConditions;