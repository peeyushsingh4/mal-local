# Success Metrics

Testable success metrics (each checkable during review without real users):

| Area | Metric | Target | How to verify |
|------|--------|--------|---------------|
| Product | Main workflow completion | Create and find a listing in under 3 minutes | Run demo script |
| Activation | First useful action | Create first listing without help | Manual demo |
| Local-first | Offline persistence | Listing survives browser refresh/close/reopen | Create → close → reopen |
| Accessibility | Core flow accessibility | Feed and create form work with screen reader | Review a11y notes and test |
| Security | Data minimization | No exact addresses, no secrets, no hosted AI keys | Review data model and repo |
| Local AI | Helpful action with fallback | AI description suggestion works without network | Disable network, test |
| Architecture | Clear boundaries | UI, storage, product logic, AI can change independently | Review ADR and code |
| Reliability | Main flow stability | No crash across feed→create→persist→reopen→details | Run demo twice |
| Custom | Neighborhood Pulse accuracy | Pulse reflects actual listing data in real-time | Create listings, check pulse |
