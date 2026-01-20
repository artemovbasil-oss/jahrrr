import React, { useState } from 'react';
import { CRMProvider } from './components/crm-context';
import { MobileScreen } from './components/mobile-screen';
import { DashboardScreen } from './components/dashboard-screen';
import { ClientDetailScreen } from './components/client-detail-screen';
import { AddClientScreen } from './components/add-client-screen';
import { AddProjectScreen } from './components/add-project-screen';
import { ProjectDetailScreen } from './components/project-detail-screen';
import { EditClientScreen } from './components/edit-client-screen';
import { EditProjectScreen } from './components/edit-project-screen';

type Screen = 
  | { type: 'dashboard' }
  | { type: 'client'; clientId: string }
  | { type: 'add-client' }
  | { type: 'add-project'; clientId?: string }
  | { type: 'project'; projectId: string }
  | { type: 'edit-client'; clientId: string }
  | { type: 'edit-project'; projectId: string };

export default function App() {
  const [screen, setScreen] = useState<Screen>({ type: 'dashboard' });

  const handleNavigate = (screenType: string, data?: any) => {
    switch (screenType) {
      case 'dashboard':
        setScreen({ type: 'dashboard' });
        break;
      case 'client':
        setScreen({ type: 'client', clientId: data.clientId });
        break;
      case 'add-client':
        setScreen({ type: 'add-client' });
        break;
      case 'add-project':
        setScreen({ type: 'add-project', clientId: data?.clientId });
        break;
      case 'project':
        setScreen({ type: 'project', projectId: data.projectId });
        break;
      case 'edit-client':
        setScreen({ type: 'edit-client', clientId: data.clientId });
        break;
      case 'edit-project':
        setScreen({ type: 'edit-project', projectId: data.projectId });
        break;
    }
  };

  return (
    <CRMProvider>
      <div className="size-full flex items-center justify-center bg-gradient-to-br from-gray-100 to-gray-200 p-8">
        <MobileScreen>
          {screen.type === 'dashboard' && (
            <DashboardScreen onNavigate={handleNavigate} />
          )}
          {screen.type === 'client' && (
            <ClientDetailScreen clientId={screen.clientId} onNavigate={handleNavigate} />
          )}
          {screen.type === 'add-client' && (
            <AddClientScreen onNavigate={handleNavigate} />
          )}
          {screen.type === 'add-project' && (
            <AddProjectScreen clientId={screen.clientId} onNavigate={handleNavigate} />
          )}
          {screen.type === 'project' && (
            <ProjectDetailScreen projectId={screen.projectId} onNavigate={handleNavigate} />
          )}
          {screen.type === 'edit-client' && (
            <EditClientScreen clientId={screen.clientId} onNavigate={handleNavigate} />
          )}
          {screen.type === 'edit-project' && (
            <EditProjectScreen projectId={screen.projectId} onNavigate={handleNavigate} />
          )}
        </MobileScreen>
      </div>
    </CRMProvider>
  );
}