export class TreeNode {
  translateKey: string;
  iconname?: string;
  hasParent: boolean = false;
  children?: TreeNode[];
  url?: string;
  disabled: boolean = false;
  exactUrl?: boolean = false;
  label?: string;

  constructor(values: {
    translateKey: string;
    iconname?: string;
    children?: TreeNode[];
    hasParent?: boolean;
    url?: string;
    disabled: boolean;
    exactUrl?: boolean;
    label?: string;
  }) {
    this.translateKey = values.translateKey;
    this.iconname = values.iconname || null;
    this.children = values.children || null;
    this.hasParent = values.hasParent || null;
    this.url = values.url || null;
    this.disabled = values.disabled;
    this.exactUrl = values.exactUrl || false;
    this.label = values.label || null;
  }
}
export class TitleNode {
  appName: string;
  appSlogan: string;
  logo?: string;
  disabled: boolean = false;
  version?: string;

  constructor(values: { appName: string; appSlogan: string; logo?: string; disabled: boolean; version?: string }) {
    this.appName = values.appName;
    this.appSlogan = values.appSlogan;
    this.logo = values.logo || null;
    this.disabled = values.disabled;
    this.version = values.version;
  }
}
