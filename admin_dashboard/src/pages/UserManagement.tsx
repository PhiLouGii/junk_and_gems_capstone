import React, { useEffect, useState } from 'react';
import { User } from '../types';
import { currentAPI } from '../services/api';
import styles from './UserManagement.module.css';

const UserManagement: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await currentAPI.getUsers();
      setUsers(response.data);
    } catch (error: any) {
      console.error('Failed to fetch users:', error);
      setError(error.response?.data?.message || 'Failed to load users');
      // For now, use empty array
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const updateUserStatus = async (userId: string, status: string) => {
  try {
    if (status === 'banned') {
      await currentAPI.banUser(userId, 'Banned by admin');
    } else {
      await currentAPI.unbanUser(userId);
    }
    fetchUsers(); // Refresh the list
  } catch (error) {
    console.error('Failed to update user status:', error);
  }
};

  if (loading) {
    return <div className={styles.loading}>Loading users...</div>;
  }

  return (
    <div className={styles.userManagement}>
      <h1>User Management</h1>
      
      {error && (
        <div className={styles.error}>
          {error} - Using fallback data
        </div>
      )}

      <div className={styles.tableContainer}>
        {users.length === 0 ? (
          <div className={styles.noData}>
            <p>No users found or user management endpoint not available.</p>
            <p>Check that the /admin/users endpoint exists in your backend.</p>
          </div>
        ) : (
          <table className={styles.usersTable}>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Points</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td>{user.points}</td>
                  <td>
                    <span className={`${styles.status} ${styles[user.status]}`}>
                      {user.status}
                    </span>
                  </td>
                  <td>
                    <div className={styles.actions}>
                      {user.status === 'active' ? (
                        <button
                          onClick={() => updateUserStatus(user.id, 'suspended')}
                          className={styles.suspendBtn}
                        >
                          Suspend
                        </button>
                      ) : (
                        <button
                          onClick={() => updateUserStatus(user.id, 'active')}
                          className={styles.activateBtn}
                        >
                          Activate
                        </button>
                      )}
                      <button className={styles.viewBtn}>View Details</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default UserManagement;