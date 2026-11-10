import React from 'react';

export interface SoftwareApplicationJsonLdProps {
  name: string;
  description: string;
  price: string;
  currency?: string;
  ratingValue?: string;
  reviewCount?: string;
  applicationCategory?: string;
  operatingSystem?: string;
}

export function SoftwareApplicationJsonLd({
  name,
  description,
  price,
  currency = 'USD',
  ratingValue = '4.9',
  reviewCount = '150',
  applicationCategory = 'BusinessApplication',
  operatingSystem = 'Cloud',
}: SoftwareApplicationJsonLdProps) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name,
    description,
    applicationCategory,
    operatingSystem,
    offers: {
      '@type': 'Offer',
      price,
      priceCurrency: currency,
      availability: 'https://schema.org/InStock',
    },
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue,
      reviewCount,
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export interface OrganizationJsonLdProps {
  name: string;
  url: string;
  logo: string;
  sameAs?: string[];
}

export function OrganizationJsonLd({
  name,
  url,
  logo,
  sameAs = [],
}: OrganizationJsonLdProps) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name,
    url,
    logo,
    sameAs,
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
