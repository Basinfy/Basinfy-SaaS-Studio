import type { Metadata } from 'next';

export interface SiteMetadataOptions {
  title: string;
  description: string;
  url: string;
  ogImage?: string;
  locale?: string;
  noIndex?: boolean;
}

export function constructMetadata({
  title,
  description,
  url,
  ogImage = '/og-image.png',
  locale = 'en_US',
  noIndex = false,
}: SiteMetadataOptions): Metadata {
  return {
    title: {
      default: title,
      template: `%s | ${title}`,
    },
    description,
    metadataBase: new URL(url),
    alternates: {
      canonical: url,
    },
    openGraph: {
      title,
      description,
      url,
      siteName: title,
      locale,
      type: 'website',
      images: [
        {
          url: ogImage,
          width: 1200,
          height: 630,
          alt: title,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [ogImage],
    },
    robots: {
      index: !noIndex,
      follow: !noIndex,
      googleBot: {
        index: !noIndex,
        follow: !noIndex,
        'max-video-preview': -1,
        'max-image-preview': 'large',
        'max-snippet': -1,
      },
    },
  };
}
