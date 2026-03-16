export class UserConfiguration {
  roles!: any[];
  userState!: UserState;

  constructor(values?: { roles?: any[]; userState: UserState }) {
    if (!values) {
      return;
    }

    this.roles = values.roles || [];
    this.userState = values.userState || null;
  }
}

export class UserState {
  tabStates!: TabState[];
  externalFilterStates!: ExternalFilterState[];

  constructor(values?: { tabStates?: TabState[]; externalFilterStates?: ExternalFilterState[] }) {
    if (!values) {
      return;
    }

    this.tabStates = values.tabStates || [];
    this.externalFilterStates = values.externalFilterStates || [];
  }
}

export class TabState {
  url!: string;
  selectedTab!: number;

  constructor(values?: { url: string; selectedTab: number }) {
    if (!values) {
      return;
    }

    this.url = values.url || '';
    this.selectedTab = values.selectedTab || 0;
  }
}

export class ExternalFilterState {
  urlGridKey!: string;
  filter: any;

  constructor(values?: { urlGridKey: string; filter: any }) {
    if (!values) {
      return;
    }

    this.urlGridKey = values.urlGridKey || '';
    this.filter = values.filter || 0;
  }
}
