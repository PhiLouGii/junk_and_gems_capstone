import React, { useEffect, useState } from 'react';
import { currentAPI } from '../services/api';
import styles from './Security.module.css';

const Security: React.FC = () => {
  const [reports, setReports] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchReports();
  }, []);

  const fetchReports = async () => {
    try {
      const response = await currentAPI.getReports();
      setReports(response.data);
    } catch (error) {
      console.error('Failed to fetch reports:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className={styles.loading}>Loading security reports...</div>;
  }

  return (
    <div className={styles.security}>
      <h1>🔒 Security & System Monitoring</h1>

      <div className={styles.reports}>
        <div className={styles.card}>
          <h2>📈 User Growth (Last 30 Days)</h2>
          {reports?.userGrowth && reports.userGrowth.length > 0 ? (
            <ul>
              {reports.userGrowth.slice(0, 10).map((item: any) => (
                <li key={item.date}>
                  {new Date(item.date).toLocaleDateString()}: {item.count} new users
                </li>
              ))}
            </ul>
          ) : (
            <p>No user growth data</p>
          )}
        </div>

        <div className={styles.card}>
          <h2>📦 Material Activity</h2>
          {reports?.materialActivity && reports.materialActivity.length > 0 ? (
            <ul>
              {reports.materialActivity.slice(0, 10).map((item: any) => (
                <li key={item.date}>
                  {new Date(item.date).toLocaleDateString()}: {item.count} materials
                </li>
              ))}
            </ul>
          ) : (
            <p>No material activity data</p>
          )}
        </div>

        <div className={styles.card}>
          <h2>💰 Revenue</h2>
          {reports?.revenue && reports.revenue.length > 0 ? (
            <ul>
              {reports.revenue.slice(0, 10).map((item: any) => (
                <li key={item.date}>
                  {new Date(item.date).toLocaleDateString()}: M {parseFloat(item.total).toFixed(2)}
                </li>
              ))}
            </ul>
          ) : (
            <p>No revenue data</p>
          )}
        </div>
      </div>
    </div>
  );
};

export default Security;