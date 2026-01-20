import React, { createContext, useContext, useState } from 'react';

export type Client = {
  id: string;
  name: string;
  type: 'retainer' | 'project';
  initials: string;
  color: string;
  salary?: number;
  payments?: number;
  totalAmount?: number;
  inProgress?: number;
  contacts: Contact[];
};

export type Contact = {
  id: string;
  name?: string;
  role?: string;
  value: string;
  type: 'name' | 'phone' | 'email' | 'social';
  isPreferred?: boolean;
};

export type Project = {
  id: string;
  clientId: string;
  name: string;
  amount: number;
  status: 'in progress' | 'waiting for feedback' | 'completed';
  deadline: string;
};

export type Event = {
  id: string;
  clientId: string;
  clientName: string;
  type: 'retainer' | 'project';
  amount: number;
  label: string;
  status: string;
  statusColor: string;
  date: string;
};

type CRMContextType = {
  clients: Client[];
  projects: Project[];
  events: Event[];
  addClient: (client: Omit<Client, 'id'>) => void;
  updateClient: (id: string, client: Partial<Client>) => void;
  deleteClient: (id: string) => void;
  addProject: (project: Omit<Project, 'id'>) => void;
  updateProject: (id: string, project: Partial<Project>) => void;
  deleteProject: (id: string) => void;
  getClient: (id: string) => Client | undefined;
  getClientProjects: (clientId: string) => Project[];
};

const CRMContext = createContext<CRMContextType | undefined>(undefined);

const initialClients: Client[] = [
  {
    id: '1',
    name: 'NDA Bank',
    type: 'retainer',
    initials: 'NB',
    color: '#77afca',
    salary: 3500,
    payments: 38500,
    contacts: [
      { id: 'c1', name: 'Ian Burgerson', role: 'Head of Design', value: 'Ian Burgerson', type: 'name' },
      { id: 'c2', value: '+90 554 019 6137', type: 'phone', isPreferred: true },
      { id: 'c3', value: 'i.burgerson@radicalcoffee.com', type: 'email' },
      { id: 'c4', value: '@iburgerson', type: 'social' },
    ],
  },
  {
    id: '2',
    name: 'Radical Coffee',
    type: 'project',
    initials: 'RC',
    color: '#e5e5e5',
    inProgress: 1280,
    totalAmount: 4250,
    contacts: [
      { id: 'c5', name: 'Ian Burgerson', role: 'Head of Design', value: 'Ian Burgerson', type: 'name' },
      { id: 'c6', value: '+90 554 019 6137', type: 'phone', isPreferred: true },
      { id: 'c7', value: 'i.burgerson@radicalcoffee.com', type: 'email' },
      { id: 'c8', value: '@iburgerson', type: 'social' },
    ],
  },
  {
    id: '3',
    name: 'Mindful decoration',
    type: 'project',
    initials: 'MD',
    color: '#c9b5a8',
    inProgress: 900,
    totalAmount: 900,
    contacts: [
      { id: 'c9', name: 'Maria Delgado', role: 'Founder', value: 'Maria Delgado', type: 'name' },
    ],
  },
];

const initialProjects: Project[] = [
  {
    id: 'p1',
    clientId: '2',
    name: 'Framer website',
    amount: 2250,
    status: 'in progress',
    deadline: '2026-01-23',
  },
  {
    id: 'p2',
    clientId: '2',
    name: 'Presentation design',
    amount: 1000,
    status: 'in progress',
    deadline: '2026-01-23',
  },
  {
    id: 'p3',
    clientId: '2',
    name: 'Branding',
    amount: 1000,
    status: 'in progress',
    deadline: '2026-01-23',
  },
  {
    id: 'p4',
    clientId: '3',
    name: 'Mindful decoration',
    amount: 900,
    status: 'waiting for feedback',
    deadline: '2026-01-23',
  },
];

const initialEvents: Event[] = [
  {
    id: 'e1',
    clientId: '1',
    clientName: 'NDA bank',
    type: 'retainer',
    amount: 3500,
    label: 'Salary',
    status: 'Next payment',
    statusColor: '#00a63e',
    date: '2026-01-10',
  },
  {
    id: 'e2',
    clientId: '2',
    clientName: 'Framer website',
    type: 'project',
    amount: 2250,
    label: 'Radical Coffee',
    status: 'In progress',
    statusColor: '#f4a526',
    date: '2026-01-23',
  },
  {
    id: 'e3',
    clientId: '3',
    clientName: 'Mindful decoration',
    type: 'project',
    amount: 900,
    label: 'Mindful decoration',
    status: 'Waiting for feedback',
    statusColor: '#ff6b6b',
    date: '2026-01-23',
  },
];

export function CRMProvider({ children }: { children: React.ReactNode }) {
  const [clients, setClients] = useState<Client[]>(initialClients);
  const [projects, setProjects] = useState<Project[]>(initialProjects);
  const [events, setEvents] = useState<Event[]>(initialEvents);

  const addClient = (client: Omit<Client, 'id'>) => {
    const newClient = { ...client, id: Date.now().toString() };
    setClients([...clients, newClient]);
  };

  const updateClient = (id: string, updates: Partial<Client>) => {
    setClients(clients.map(c => c.id === id ? { ...c, ...updates } : c));
  };

  const deleteClient = (id: string) => {
    setClients(clients.filter(c => c.id !== id));
    setProjects(projects.filter(p => p.clientId !== id));
  };

  const addProject = (project: Omit<Project, 'id'>) => {
    const newProject = { ...project, id: Date.now().toString() };
    setProjects([...projects, newProject]);
  };

  const updateProject = (id: string, updates: Partial<Project>) => {
    setProjects(projects.map(p => p.id === id ? { ...p, ...updates } : p));
  };

  const deleteProject = (id: string) => {
    setProjects(projects.filter(p => p.id !== id));
  };

  const getClient = (id: string) => clients.find(c => c.id === id);

  const getClientProjects = (clientId: string) => projects.filter(p => p.clientId === clientId);

  return (
    <CRMContext.Provider
      value={{
        clients,
        projects,
        events,
        addClient,
        updateClient,
        deleteClient,
        addProject,
        updateProject,
        deleteProject,
        getClient,
        getClientProjects,
      }}
    >
      {children}
    </CRMContext.Provider>
  );
}

export function useCRM() {
  const context = useContext(CRMContext);
  if (!context) {
    throw new Error('useCRM must be used within a CRMProvider');
  }
  return context;
}
