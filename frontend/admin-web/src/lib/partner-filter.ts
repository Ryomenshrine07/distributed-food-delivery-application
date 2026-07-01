import type { DeliveryPartner } from '@/services/delivery';

/**
 * Delivery-partner filter predicate (Req 14.3).
 *
 * The three filters are derived from data already loaded on the partners page:
 *   - `online`    -> `partner.online === true`
 *   - `available` -> `partner.available === true`
 *   - `assigned`  -> `partner.currentAssignmentId != null` (a non-null current assignment)
 *
 * `filterPartners` is PURE. With no active filters it returns the list unchanged
 * (show all); otherwise a partner must satisfy EVERY active filter (AND semantics).
 */
export type PartnerFilter = 'online' | 'available' | 'assigned';

export function partnerMatchesFilter(partner: DeliveryPartner, filter: PartnerFilter): boolean {
  switch (filter) {
    case 'online':
      return partner.online === true;
    case 'available':
      return partner.available === true;
    case 'assigned':
      return partner.currentAssignmentId != null;
    default:
      return false;
  }
}

export function filterPartners(
  partners: DeliveryPartner[],
  activeFilters: Set<PartnerFilter>,
): DeliveryPartner[] {
  if (activeFilters.size === 0) return partners;
  return partners.filter((partner) =>
    [...activeFilters].every((filter) => partnerMatchesFilter(partner, filter)),
  );
}
