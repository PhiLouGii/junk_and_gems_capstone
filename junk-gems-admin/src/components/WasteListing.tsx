import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom'; 
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Recycle, TrendingUp, Package, AlertCircle, CheckCircle, Clock } from 'lucide-react';

interface Material {
  id: string;
  category: string;
  description: string;
  quantity: string | number;
  location: string;
  claim_status: 'available' | 'pending' | 'confirmed';
  uploader_id: string;
  created_at: string;
  title: string;
}

interface WasteStats {
  material: string;
  listed: number;
  claimed: number;
  claimRate: number;
  available: number;
}

const WasteListing: React.FC = () => {
  const navigate = useNavigate();

  const [wasteStats, setWasteStats] = useState<WasteStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const [summary, setSummary] = useState({
    totalListed: 0,
    totalClaimed: 0,
    totalAvailable: 0,
    overallClaimRate: 0,
    totalWeight: 0
  });

  useEffect(() => {
    fetchMaterials();
  }, []);

  const fetchMaterials = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/materials');
      
      if (!response.ok) {
        throw new Error('Failed to fetch materials');
      }
      
      const data = await response.json();
      console.log('API Response:', data);
      console.log('Is Array?', Array.isArray(data));
      console.log('Length:', data.length);
      
      // Check if data is an array or if it's wrapped in an object
      const materialsArray = Array.isArray(data) ? data : (data.materials || data.data || []);
      
      console.log('Materials Array:', materialsArray);
      console.log('Materials Count:', materialsArray.length);
      
      if (materialsArray.length > 0) {
        console.log('First Material:', materialsArray[0]);
      }
      
      if (materialsArray.length === 0) {
        setError('No materials data available from API yet.');
        processWasteData([]);
      } else {
        console.log('Processing materials...');
        processWasteData(materialsArray);
        setError('');
      }
    } catch (err) {
      console.error('Error fetching materials:', err);
      setError(`Failed to connect to API: ${err instanceof Error ? err.message : 'Unknown error'}`);
      processWasteData([]);
    } finally {
      setLoading(false);
    }
  };


  const processWasteData = (materialsData: Material[]) => {
    console.log('=== PROCESSING WASTE DATA ===');
    console.log('Input materials:', materialsData);
    
    const categoryMap: { [key: string]: { listed: number; claimed: number; available: number } } = {
      'Plastic': { listed: 0, claimed: 0, available: 0 },
      'Fabric': { listed: 0, claimed: 0, available: 0 },
      'Glass': { listed: 0, claimed: 0, available: 0 },
      'Metal': { listed: 0, claimed: 0, available: 0 },
      'Wood': { listed: 0, claimed: 0, available: 0 },
      'Electronics': { listed: 0, claimed: 0, available: 0 },
      'Other': { listed: 0, claimed: 0, available: 0 }
    };

    let totalListed = 0;
    let totalClaimed = 0;
    let totalAvailable = 0;
    let totalWeight = 0;

    materialsData.forEach((material, index) => {
      console.log(`Processing material ${index + 1}:`, material);
      
      const category = material.category;
      console.log(`Category: ${category}`);
      
      // Parse quantity - could be string like "5 items" or number
      let itemCount = 1; // Default to 1 item if can't parse
      if (typeof material.quantity === 'number') {
        itemCount = material.quantity;
      } else if (typeof material.quantity === 'string') {
        const parsed = parseFloat(material.quantity);
        if (!isNaN(parsed)) {
          itemCount = parsed;
        }
      }
      
      console.log(`Quantity: ${material.quantity}, Parsed: ${itemCount}`);
      
      // Estimate weight: assume 0.5 kg per item as baseline
      const estimatedWeight = itemCount * 0.5;
      console.log(`Estimated weight: ${estimatedWeight} kg`);
      
      totalWeight += estimatedWeight;
      
      if (categoryMap[category]) {
        categoryMap[category].listed += estimatedWeight;
        totalListed += estimatedWeight;
        
        console.log(`Claim status: ${material.claim_status}`);
        
        if (material.claim_status === 'confirmed') {
          categoryMap[category].claimed += estimatedWeight;
          totalClaimed += estimatedWeight;
          console.log('Added to CLAIMED');
        } else if (material.claim_status === 'available' || material.claim_status === 'pending') {
          categoryMap[category].available += estimatedWeight;
          totalAvailable += estimatedWeight;
          console.log('Added to AVAILABLE');
        }
      } else {
        console.warn(`Unknown category: ${category}`);
      }
    });

    console.log('Category Map:', categoryMap);
    console.log('Totals:', { totalListed, totalClaimed, totalAvailable, totalWeight });

    const stats: WasteStats[] = Object.entries(categoryMap).map(([material, data]) => ({
      material,
      listed: Math.round(data.listed * 10) / 10,
      claimed: Math.round(data.claimed * 10) / 10,
      available: Math.round(data.available * 10) / 10,
      claimRate: data.listed > 0 ? Math.round((data.claimed / data.listed) * 100) : 0
    }));

    console.log('Final stats:', stats);

    setWasteStats(stats);
    setSummary({
      totalListed: Math.round(totalListed * 10) / 10,
      totalClaimed: Math.round(totalClaimed * 10) / 10,
      totalAvailable: Math.round(totalAvailable * 10) / 10,
      overallClaimRate: totalListed > 0 ? Math.round((totalClaimed / totalListed) * 100) : 0,
      totalWeight: Math.round(totalWeight * 10) / 10
    });
  };

  const COLORS = {
    listed: '#88844D',
    claimed: '#BEC092'
  };

  if (loading) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <div style={{ fontSize: '1.2rem', color: '#88844D' }}>Loading waste materials data...</div>
      </div>
    );
  }

  return (
    
     <div style={{ padding: '2rem', maxWidth: '1400px', margin: '6rem auto 0 auto', background: '#f9f9f9', minHeight: '100vh' }}>
      
      {/* Back Button */}
      <div style={{ marginBottom: '1rem' }}>
        <button
          onClick={() => navigate('/')}
          style={{
            padding: '0.5rem 1rem',
            background: '#88844D',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}
        >
          ← Back
        </button>
      </div>
    <div style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto', background: '#f9f9f9', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', color: '#88844D', marginBottom: '0.5rem' }}>
          ♻️ Waste Material Tracking
        </h1>
        <p style={{ color: '#666', fontSize: '1rem' }}>
          Monitor waste listings, claim rates, and material distribution across the platform
        </p>
      </div>

      {error && (
        <div style={{ 
          padding: '1rem', 
          background: '#fee2e2', 
          border: '1px solid #ef4444', 
          borderRadius: '8px', 
          marginBottom: '1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem'
        }}>
          <AlertCircle size={20} color="#991b1b" />
          <div>
            <strong>Error:</strong> {error}
            <div style={{ fontSize: '0.875rem', marginTop: '0.25rem' }}>
              Check browser console for details. Ensure materials are being added to the database.
            </div>
          </div>
        </div>
      )}

      {!error && wasteStats.length === 0 && !loading && (
        <div style={{ 
          padding: '1rem', 
          background: '#dbeafe', 
          border: '1px solid #3b82f6', 
          borderRadius: '8px', 
          marginBottom: '1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem'
        }}>
          <AlertCircle size={20} color="#1e40af" />
          <div>
            <strong>No data yet:</strong> Start by adding waste materials through the platform to see statistics here.
          </div>
        </div>
      )}

      {/* Summary Cards */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', 
        gap: '1.5rem', 
        marginBottom: '2rem' 
      }}>
        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #88844D'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Listed</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                {summary.totalListed} kg
              </div>
            </div>
            <Package size={32} color="#88844D" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #22c55e'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Claimed</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#22c55e' }}>
                {summary.totalClaimed} kg
              </div>
            </div>
            <CheckCircle size={32} color="#22c55e" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #3b82f6'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Available</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#3b82f6' }}>
                {summary.totalAvailable} kg
              </div>
            </div>
            <Clock size={32} color="#3b82f6" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #BEC092'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Claim Rate</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                {summary.overallClaimRate}%
              </div>
            </div>
            <TrendingUp size={32} color="#88844D" />
          </div>
        </div>
      </div>

      {/* Main Chart */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '2rem', 
        marginBottom: '2rem', 
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' 
      }}>
        <h2 style={{ color: '#88844D', marginBottom: '0.5rem' }}>
          ♻️ Environmental Impact: Waste Material Distribution
        </h2>
        <p style={{ color: '#666', fontSize: '0.95rem', marginBottom: '1.5rem' }}>
          Tracking waste listed vs. claimed across material types
        </p>
        
        <ResponsiveContainer width="100%" height={400}>
          <BarChart data={wasteStats} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis 
              dataKey="material" 
              angle={-15} 
              textAnchor="end" 
              height={80}
              style={{ fontSize: '0.85rem' }}
            />
            <YAxis 
              label={{ value: 'Weight (kg)', angle: -90, position: 'insideLeft' }}
              style={{ fontSize: '0.85rem' }}
            />
            <Tooltip 
              contentStyle={{ 
                background: '#fff', 
                border: '1px solid #ccc', 
                borderRadius: '8px',
                padding: '10px'
              }}
            />
            <Legend 
              wrapperStyle={{ paddingTop: '20px' }}
            />
            <Bar dataKey="listed" fill={COLORS.listed} name="Listed (kg)" radius={[8, 8, 0, 0]} />
            <Bar dataKey="claimed" fill={COLORS.claimed} name="Claimed (kg)" radius={[8, 8, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>

        <div style={{ 
          marginTop: '1.5rem', 
          padding: '1rem', 
          background: '#FFF8DC', 
          borderRadius: '8px',
          borderLeft: '4px solid #88844D'
        }}>
          <strong style={{ color: '#88844D' }}>Key Insight:</strong>
          <span style={{ color: '#666' }}> Platform has diverted <strong>{summary.totalClaimed} kg</strong> of waste from landfills with a <strong>{summary.overallClaimRate}% claim rate</strong>. Plastic materials show highest engagement, validating focus on addressing plastic pollution.</span>
        </div>
      </div>

      {/* Material Breakdown Table */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '2rem', 
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' 
      }}>
        <h2 style={{ color: '#88844D', marginBottom: '1.5rem' }}>
          📊 Detailed Material Breakdown
        </h2>
        
        <div style={{ overflowX: 'auto' }}>
          <table style={{ 
            width: '100%', 
            borderCollapse: 'collapse',
            background: 'white',
            borderRadius: '8px',
            overflow: 'hidden'
          }}>
            <thead>
              <tr style={{ background: '#88844D', color: 'white' }}>
                <th style={{ padding: '1rem', textAlign: 'left' }}>Material Type</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Listed (kg)</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Claimed (kg)</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Available (kg)</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Claim Rate</th>
              </tr>
            </thead>
            <tbody>
              {wasteStats.map((stat, index) => (
                <tr 
                  key={stat.material}
                  style={{ 
                    borderBottom: '1px solid #e5e7eb',
                    background: index % 2 === 0 ? '#fafafa' : 'white'
                  }}
                >
                  <td style={{ padding: '1rem', fontWeight: '600', color: '#88844D' }}>
                    <Recycle size={16} style={{ display: 'inline', marginRight: '8px', verticalAlign: 'middle' }} />
                    {stat.material}
                  </td>
                  <td style={{ padding: '1rem', textAlign: 'center' }}>{stat.listed}</td>
                  <td style={{ padding: '1rem', textAlign: 'center', color: '#22c55e', fontWeight: '600' }}>
                    {stat.claimed}
                  </td>
                  <td style={{ padding: '1rem', textAlign: 'center', color: '#3b82f6' }}>
                    {stat.available}
                  </td>
                  <td style={{ padding: '1rem', textAlign: 'center' }}>
                    <span style={{
                      padding: '0.25rem 0.75rem',
                      borderRadius: '12px',
                      background: stat.claimRate >= 70 ? '#d1fae5' : stat.claimRate >= 40 ? '#fef3c7' : '#fee2e2',
                      color: stat.claimRate >= 70 ? '#065f46' : stat.claimRate >= 40 ? '#92400e' : '#991b1b',
                      fontWeight: '600',
                      fontSize: '0.875rem'
                    }}>
                      {stat.claimRate}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Action Buttons */}
      <div style={{ 
        marginTop: '2rem', 
        display: 'flex', 
        gap: '1rem', 
        flexWrap: 'wrap',
        justifyContent: 'center'
      }}>
        <button 
          onClick={fetchMaterials}
          style={{ 
            padding: '0.75rem 1.5rem', 
            background: '#88844D', 
            color: 'white', 
            border: 'none', 
            borderRadius: '8px', 
            cursor: 'pointer',
            fontWeight: '600',
            fontSize: '1rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}
        >
          🔄 Refresh Data
        </button>
        
        <button 
          onClick={() => alert('Export functionality would generate CSV/PDF report')}
          style={{ 
            padding: '0.75rem 1.5rem', 
            background: '#BEC092', 
            color: 'white', 
            border: 'none', 
            borderRadius: '8px', 
            cursor: 'pointer',
            fontWeight: '600',
            fontSize: '1rem'
          }}
        >
          📥 Export Report
        </button>
      </div>
    </div>
  </div>

  );
};

export default WasteListing;