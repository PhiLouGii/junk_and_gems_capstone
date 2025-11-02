import React, { useEffect, useState } from 'react';
import { currentAPI } from '../services/api';
import styles from './PointSystem.module.css';

interface LeaderboardUser {
  id: number;
  name: string;
  email: string;
  available_gems: number;
  donation_count: number;
}

const PointSystem: React.FC = () => {
  const [leaderboard, setLeaderboard] = useState<LeaderboardUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [adjustUserId, setAdjustUserId] = useState('');
  const [adjustGems, setAdjustGems] = useState('');
  const [adjustReason, setAdjustReason] = useState('');

  useEffect(() => {
    fetchLeaderboard();
  }, []);

  const fetchLeaderboard = async () => {
    try {
      const response = await currentAPI.getPointsLeaderboard();
      setLeaderboard(response.data);
    } catch (error) {
      console.error('Failed to fetch leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAdjustGems = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await currentAPI.adjustUserPoints(
        adjustUserId,
        parseInt(adjustGems),
        adjustReason
      );
      alert('Gems adjusted successfully!');
      setAdjustUserId('');
      setAdjustGems('');
      setAdjustReason('');
      fetchLeaderboard();
    } catch (error) {
      alert('Failed to adjust gems');
      console.error(error);
    }
  };

  if (loading) {
    return <div className={styles.loading}>Loading...</div>;
  }

  return (
    <div className={styles.pointSystem}>
      <h1>💎 Gems Leaderboard</h1>

      <div className={styles.leaderboard}>
        <table>
          <thead>
            <tr>
              <th>Rank</th>
              <th>Name</th>
              <th>Email</th>
              <th>Gems</th>
              <th>Donations</th>
            </tr>
          </thead>
          <tbody>
            {leaderboard.map((user, index) => (
              <tr key={user.id}>
                <td>{index + 1}</td>
                <td>{user.name}</td>
                <td>{user.email}</td>
                <td>💎 {user.available_gems}</td>
                <td>{user.donation_count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className={styles.adjustGems}>
        <h2>Adjust User Gems</h2>
        <form onSubmit={handleAdjustGems}>
          <input
            type="text"
            placeholder="User ID"
            value={adjustUserId}
            onChange={(e) => setAdjustUserId(e.target.value)}
            required
          />
          <input
            type="number"
            placeholder="Gems Amount (positive or negative)"
            value={adjustGems}
            onChange={(e) => setAdjustGems(e.target.value)}
            required
          />
          <input
            type="text"
            placeholder="Reason"
            value={adjustReason}
            onChange={(e) => setAdjustReason(e.target.value)}
            required
          />
          <button type="submit">Adjust Gems</button>
        </form>
      </div>
    </div>
  );
};

export default PointSystem;