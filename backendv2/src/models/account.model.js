export function validateAccountPayload(p) {
  if (!p) throw new Error('Empty payload');
  if (!p.accountNumber) throw new Error('accountNumber required');
  if (!p.legalName) throw new Error('legalName required');
  if (!p.edrpou) throw new Error('edrpou required');
}
