import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--outline button--secondary button--lg"
            to="/docs/comparisons/framework-comparison"
            style={{marginLeft: '10px'}}>
            Why Superior to React Native? 🚀
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - Flutter Modular Architecture`}
      description="The definitive guide to building scalable cross-platform applications with modular Flutter architecture that surpasses React Native, Ionic, and traditional approaches.">
      <HomepageHeader />
      <main>

        {/* Architecture Highlights Section */}
        <section className={styles.architectureSection}>
          <div className="container">
            <div className="row">
              <div className="col col--12">
                <div className="text--center">
                  <Heading as="h2">Why This Architecture Dominates</Heading>
                  <p className="margin-bottom--lg">
                    While other frameworks force compromises, our modular Flutter SuperApp architecture delivers everything:
                    performance, scalability, and developer experience.
                  </p>
                </div>
              </div>
            </div>

            <div className="row">
              <div className="col col--4">
                <div className="text--center padding-horiz--md">
                  <h3>🏆 vs React Native</h3>
                  <p>
                    Native performance without JavaScript bridge bottlenecks.
                    True modular architecture vs component-based coupling.
                  </p>
                </div>
              </div>
              <div className="col col--4">
                <div className="text--center padding-horiz--md">
                  <h3>⚡ vs Ionic/Cordova</h3>
                  <p>
                    Native compilation vs WebView performance penalties.
                    60fps animations vs stuttering web interfaces.
                  </p>
                </div>
              </div>
              <div className="col col--4">
                <div className="text--center padding-horiz--md">
                  <h3>🎯 vs Traditional Flutter</h3>
                  <p>
                    Independent module deployment vs monolithic releases.
                    Unlimited team scaling vs bottlenecked development.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Enterprise Benefits Section */}
        <section className={styles.enterpriseSection}>
          <div className="container">
            <div className="row">
              <div className="col col--6">
                <Heading as="h2">Enterprise-Grade Benefits</Heading>
                <ul>
                  <li><strong>Team Scalability:</strong> Unlimited parallel development teams</li>
                  <li><strong>Risk Mitigation:</strong> Module failures don't crash the app</li>
                  <li><strong>Deployment Flexibility:</strong> Deploy features independently</li>
                  <li><strong>A/B Testing:</strong> Test different module versions simultaneously</li>
                  <li><strong>Cost Efficiency:</strong> Right-size teams for specific modules</li>
                </ul>
                <div className="margin-top--md">
                  <Link
                    className="button button--primary button--lg"
                    to="/docs/architecture/overview">
                    Explore the Architecture →
                  </Link>
                </div>
              </div>
              <div className="col col--6">
                <div className={styles.codeExample}>
                  <pre>
                    <code>{`// Independent module deployment
Team A: Deploys Home module v2.1.0 ✅
Team B: Deploys Profile module v1.5.0 ✅
Team C: Deploys Jobs module v3.0.0 ✅

// No conflicts, no waiting, no dependencies
// Each team owns their module lifecycle`}</code>
                  </pre>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
