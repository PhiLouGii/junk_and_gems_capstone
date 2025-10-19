import { useEffect, useRef } from 'react';
import { websocket } from '../services/websocket';
import { api } from '../services/api';

export const useWebSocket = (events: { [key: string]: (data: any) => void }) => {
  const callbacksRef = useRef(events);

  useEffect(() => {
    callbacksRef.current = events;
  }, [events]);

  useEffect(() => {
    const token = api.getToken();
    if (!token) return;

    websocket.connect(token);

    Object.entries(callbacksRef.current).forEach(([event, callback]) => {
      websocket.on(event, callback);
    });

    return () => {
      Object.entries(callbacksRef.current).forEach(([event, callback]) => {
        websocket.off(event, callback);
      });
    };
  }, []);
};