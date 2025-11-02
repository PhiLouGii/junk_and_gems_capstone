import React, { useEffect, useState } from 'react';
import { WasteListing } from '../types';
import { currentAPI } from '../services/api';
import styles from './WasteListings.module.css';

const WasteListings: React.FC = () => {
  const [listings, setListings] = useState<WasteListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');

  useEffect(() => {
    fetchListings();
  }, []);

  const fetchListings = async () => {
    try {
      const response = await currentAPI.getProducts();
      setListings(response.data);
    } catch (error) {
      console.error('Failed to fetch listings:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateListingStatus = async (listingId: string, status: string) => {
    try {
      await currentAPI.updateProduct(listingId, { status });
      fetchListings(); // Refresh the list
    } catch (error) {
      console.error('Failed to update listing status:', error);
    }
  };

  const filteredListings = filter === 'all' 
    ? listings 
    : listings.filter(listing => listing.status === filter);

  if (loading) {
    return <div className={styles.loading}>Loading listings...</div>;
  }

  return (
    <div className={styles.wasteListings}>
      <div className={styles.header}>
        <h1>Waste Listings Management</h1>
        <div className={styles.filters}>
          <button 
            className={filter === 'all' ? styles.active : ''}
            onClick={() => setFilter('all')}
          >
            All ({listings.length})
          </button>
          <button 
            className={filter === 'pending' ? styles.active : ''}
            onClick={() => setFilter('pending')}
          >
            Pending ({listings.filter(l => l.status === 'pending').length})
          </button>
          <button 
            className={filter === 'approved' ? styles.active : ''}
            onClick={() => setFilter('approved')}
          >
            Approved ({listings.filter(l => l.status === 'approved').length})
          </button>
        </div>
      </div>

      <div className={styles.listingsGrid}>
        {filteredListings.map((listing) => (
          <div key={listing.id} className={styles.listingCard}>
            <div className={styles.listingHeader}>
              <h3>{listing.title}</h3>
              <span className={`${styles.status} ${styles[listing.status]}`}>
                {listing.status}
              </span>
            </div>
            <p className={styles.description}>{listing.description}</p>
            <div className={styles.listingDetails}>
              <span>Category: {listing.category}</span>
              <span>Price: ${listing.price}</span>
              <span>Created: {new Date(listing.createdAt).toLocaleDateString()}</span>
            </div>
            <div className={styles.actions}>
              {listing.status === 'pending' && (
                <>
                  <button 
                    onClick={() => updateListingStatus(listing.id, 'approved')}
                    className={styles.approveBtn}
                  >
                    Approve
                  </button>
                  <button 
                    onClick={() => updateListingStatus(listing.id, 'rejected')}
                    className={styles.rejectBtn}
                  >
                    Reject
                  </button>
                </>
              )}
              <button className={styles.viewBtn}>View Details</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default WasteListings;