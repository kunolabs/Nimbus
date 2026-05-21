export const NIMBUS_RELEASE_REPO_OWNER = 'kunolabs';
export const NIMBUS_RELEASE_REPO_NAME = 'Nimbus';
export const NIMBUS_RELEASE_TAG_PREFIX = 'nimbus-v';

export const NIMBUS_RELEASES_API_URL = `https://api.github.com/repos/${NIMBUS_RELEASE_REPO_OWNER}/${NIMBUS_RELEASE_REPO_NAME}/releases`;
export const NIMBUS_ISSUE_REPORT_URL = `https://github.com/${NIMBUS_RELEASE_REPO_OWNER}/${NIMBUS_RELEASE_REPO_NAME}/issues/new`;

const NIMBUS_RELEASE_TAG_PATTERN =
  /^nimbus-v\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/i;

export function normalizeReleaseTag(tag: string): string {
  let normalized = (tag || '').trim().replace(/\.md$/i, '');
  if (normalized.toLowerCase().startsWith(NIMBUS_RELEASE_TAG_PREFIX)) {
    normalized = normalized.slice(NIMBUS_RELEASE_TAG_PREFIX.length);
  } else if (normalized.startsWith('v') || normalized.startsWith('V')) {
    normalized = normalized.slice(1);
  }
  return normalized;
}

export function normalizeReleaseTagKey(tag: string): string {
  return normalizeReleaseTag(tag).toLowerCase();
}

export function isNimbusReleaseTag(tag: string): boolean {
  return NIMBUS_RELEASE_TAG_PATTERN.test((tag || '').trim().replace(/\.md$/i, ''));
}
