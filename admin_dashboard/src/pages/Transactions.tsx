import React, { useEffect, useState } from 'react';
import { Transaction } from '../types';
import { currentAPI } from '../services/api';
import styles from './Transactions.module.css';

const Transactions: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTransactions();
  }, []);

  const fetchTransactions = async () => {
    try {
      const response = await currentAPI.getTransactions();
      setTransactions(response.data);
    } catch (error) {
      console.error('Failed to fetch transactions:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className={styles.loading}>Loading transactions...</div>;
  }

  return (
    <div className={styles.transactions}>
      <h1>Transaction History</h1>
      <div className={styles.tableContainer}>
        <table className={styles.transactionsTable}>
          <thead>
            <tr>
              <th>ID</th>
              <th>User</th>
              <th>Type</th>
              <th>Amount</th>
              <th>Points</th>
              <th>Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((transaction) => (
              <tr key={transaction.id}>
                <td>#{transaction.id}</td>
                <td>{transaction.userName}</td>
                <td>
                  <span className={`${styles.type} ${styles[transaction.type]}`}>
                    {transaction.type}
                  </span>
                </td>
                <td>${transaction.amount}</td>
                <td>{transaction.points} pts</td>
                <td>
                  <span className={`${styles.status} ${styles[transaction.status]}`}>
                    {transaction.status}
                  </span>
                </td>
                <td>{new Date(transaction.timestamp).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Transactions;